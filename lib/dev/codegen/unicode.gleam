import chartable/internal
import chartable/unicode/category.{type GeneralCategory}
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/string
import splitter

pub type Record(data) {
  Record(codepoint_range: CodepointRange, data: data)
}

pub type CodepointRange {
  CodepointRange(from: UtfCodepoint, to: UtfCodepoint)
  SingleCodepoint(UtfCodepoint)
  AllSurrogates
  HighSurrogates
  HighStandardSurrogates
  HighPrivateUseSurrogates
  LowSurrogates
}

pub fn codepoint_range_to_pair(codepoint_range: CodepointRange) -> #(Int, Int) {
  case codepoint_range {
    CodepointRange(from: start, to: end) -> #(
      string.utf_codepoint_to_int(start),
      string.utf_codepoint_to_int(end),
    )
    SingleCodepoint(cp) -> {
      let cp = string.utf_codepoint_to_int(cp)
      #(cp, cp)
    }
    AllSurrogates -> #(0xD800, 0xDFFF)
    HighSurrogates -> #(0xDB80, 0xDBFF)
    HighStandardSurrogates -> #(0xD800, 0xDB7F)
    HighPrivateUseSurrogates -> #(0xDB80, 0xDBFF)
    LowSurrogates -> #(0xDC00, 0xDFFF)
  }
}

pub fn records_to_string(
  records: List(Record(data)),
  data_to_string: fn(data) -> String,
) -> String {
  list.sort(records, fn(lhs, rhs) {
    let #(lhs_start, lhs_end) = codepoint_range_to_pair(lhs.codepoint_range)
    let #(rhs_start, rhs_end) = codepoint_range_to_pair(rhs.codepoint_range)
    int.compare(lhs_start, rhs_start)
    |> order.break_tie(int.compare(lhs_end, rhs_end))
  })
  |> list.map(fn(record) {
    let index = case record.codepoint_range {
      SingleCodepoint(cp) -> {
        let hex = internal.codepoint_to_hex(cp)
        let str = string.from_utf_codepoints([cp])
        hex <> " (" <> str <> ")"
      }
      codepoint_range -> {
        let #(start, end) = codepoint_range_to_pair(codepoint_range)
        internal.int_to_hex(start) <> ".." <> internal.int_to_hex(end)
      }
    }
    index <> ": " <> data_to_string(record.data)
  })
  |> string.join("\n")
}

pub fn make_name_map(
  names names: List(Record(String)),
  template template: String,
) -> String {
  let if_ranges =
    list.filter_map(names, fn(record) {
      case record {
        Record(CodepointRange(from: start, to: end), name) if name != "" -> {
          let start = internal.codepoint_to_hex(start)
          let end = internal.codepoint_to_hex(end)
          let indentation = "    "
          // if ((0x3400 <= cp) && (cp <= 0x4DBF)) {
          //   return new Ok("CJK UNIFIED IDEOGRAPH-" + int_to_hex(cp));
          // }
          let if_in_range =
            "if ((0x" <> start <> " <= cp) && (cp <= 0x" <> end <> ")) {\n"
          let name =
            string.split(name, on: "*")
            |> list.map(fn(str) { "\"" <> str <> "\"" })
            |> list.intersperse(with: "int_to_hex(cp)")
            |> list.filter(fn(str) { str != "\"\"" })
            |> string.join(" + ")
          let return_name = "  return new Ok(" <> name <> ");\n"
          Ok(if_in_range <> indentation <> return_name <> indentation <> "}")
        }
        _ -> Error(Nil)
      }
    })
    |> string.join(" else ")

  let map_def =
    list.filter_map(names, fn(record) {
      case record {
        Record(SingleCodepoint(cp), name) if name != "" -> {
          let cp = internal.codepoint_to_hex(cp)
          // TODO assert name is (uppercase letter + space + dash)
          let name = string.replace(in: name, each: "*", with: cp)
          // [0x0020, "SPACE"],
          Ok("[0x" <> cp <> ", \"" <> name <> "\"]")
        }
        _ -> Error(Nil)
      }
    })
    |> string.join(",\n")

  string.replace(in: template, each: "/*{{if_ranges}}*/", with: if_ranges)
  |> string.replace(each: "/*{{map_def}}*/", with: map_def)
}

pub fn make_block_map(
  blocks blocks: List(Record(String)),
  template template: String,
) -> String {
  let blocks =
    list.map(blocks, fn(record) {
      let #(start, end) = codepoint_range_to_pair(record.codepoint_range)
      let start = internal.int_to_hex(start)
      let end = internal.int_to_hex(end)
      let block_name = record.data
      // [[0x0000, 0x007F], "Basic Latin"]
      "[[0x" <> start <> ", 0x" <> end <> "], \"" <> block_name <> "\"]"
    })
    |> string.join(with: ",\n")
  string.replace(in: template, each: "/*{{blocks}}*/", with: blocks)
}

// =============================================================================
// BEGIN UNIDATA PARSERS

type ParserState(data) {
  ParserState(line: Int, txt: String, record: Option(Record(data)))
}

pub type ParserError {
  InvalidCodepointRange(line: Int)
  InvalidFields(line: Int)
}

fn parse_unidata(
  txt: String,
  with fields_parser: fn(List(String)) -> Result(data, Nil),
) -> Result(List(Record(data)), ParserError) {
  let line_end = splitter.new(["\n"])
  let comment = splitter.new(["#"])
  let separator = splitter.new([";"])

  let initialize_parser = ParserState(line: 0, txt:, record: None)
  use state <- parse_unidata_loop(input: initialize_parser, output: [])
  let #(line, _, rest) = splitter.split(line_end, state.txt)
  let #(line, _, _) = splitter.split(comment, line)
  use <- bool.guard(
    when: string.is_empty(line),
    return: Ok(ParserState(line: state.line + 1, txt: rest, record: None)),
  )
  let #(first_field, _, other_fields) = splitter.split(separator, line)
  use codepoint_range <- result.try(result.replace_error(
    parse_codepoint_range(string.trim(first_field)),
    InvalidCodepointRange(state.line),
  ))
  let fields =
    string.split(other_fields, on: ";")
    |> list.map(string.trim)
    |> fields_parser()
  case fields {
    Ok(data) ->
      Ok(ParserState(
        Some(Record(codepoint_range:, data:)),
        line: state.line + 1,
        txt: rest,
      ))
    Error(_) -> Error(InvalidFields(state.line))
  }
}

fn parse_unidata_loop(
  input state: ParserState(data),
  output records: List(Record(data)),
  with line_parser: fn(ParserState(data)) ->
    Result(ParserState(data), ParserError),
) -> Result(List(Record(data)), ParserError) {
  case state.txt {
    "" -> Ok(list.reverse(records))
    _ ->
      case line_parser(state) {
        Ok(state) -> {
          case state.record {
            Some(record) -> {
              let output = [record, ..records]
              parse_unidata_loop(state, output:, with: line_parser)
            }
            None ->
              parse_unidata_loop(state, output: records, with: line_parser)
          }
        }
        Error(parser_error) -> Error(parser_error)
      }
  }
}

fn parse_codepoint_range(str: String) -> Result(CodepointRange, Nil) {
  case string.split_once(str, on: "..") {
    Ok(#(start, end)) -> {
      let start = internal.parse_codepoint(start)
      let end = internal.parse_codepoint(end)
      case start, end, str {
        Ok(start), Ok(end), _ -> Ok(CodepointRange(from: start, to: end))
        _, _, "D800..DFFF" -> Ok(AllSurrogates)
        _, _, "D800..DBFF" -> Ok(HighSurrogates)
        _, _, "D800..DB7F" -> Ok(HighStandardSurrogates)
        _, _, "DB80..DBFF" -> Ok(HighPrivateUseSurrogates)
        _, _, "DC00..DFFF" -> Ok(LowSurrogates)
        _, _, _ -> Error(Nil)
      }
    }
    Error(_) -> {
      internal.parse_codepoint(str)
      |> result.map(SingleCodepoint)
    }
  }
}

pub fn parse_names(txt: String) -> Result(List(Record(String)), ParserError) {
  use data <- parse_unidata(txt)
  case data {
    [name, ..] -> Ok(name)
    [] -> Error(Nil)
  }
}

pub fn parse_categories(
  txt: String,
) -> Result(List(Record(GeneralCategory)), ParserError) {
  use data <- parse_unidata(txt)
  case data {
    [cat, ..] -> category.from_abbreviation(cat)
    [] -> Error(Nil)
  }
}

pub fn parse_blocks(txt: String) -> Result(List(Record(String)), ParserError) {
  use data <- parse_unidata(txt)
  case data {
    [block_name, ..] -> Ok(block_name)
    [] -> Error(Nil)
  }
}

// END

pub fn assert_match_unidata(
  records: List(Record(data)),
  codegen_match_record: fn(Int, data) -> Bool,
) -> Nil {
  use record <- list.each(records)
  let #(start, end) = codepoint_range_to_pair(record.codepoint_range)
  use cp <- list.each(list.range(start, end))
  assert codegen_match_record(cp, record.data)
}
