import chartable/internal
import chartable/unicode/category.{type GeneralCategory}
import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import splitter

pub type Record(fields) {
  Record(codepoint_range: CodepointRange, fields: fields)
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

pub type ParserError {
  InvalidCodepointRange(line: Int)
  InvalidFields(line: Int)
}

type ParserState(fields) {
  ParserState(line: Int, txt: String, record: Option(Record(fields)))
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
          //   return new Ok("CJK UNIFIED IDEOGRAPH-" + display_codepoint(cp));
          // }
          let if_in_range =
            "if ((0x" <> start <> " <= cp) && (cp <= 0x" <> end <> ")) {\n"
          let name =
            string.split(name, on: "*")
            |> list.map(fn(str) { "\"" <> str <> "\"" })
            |> list.intersperse(with: "display_codepoint(cp)")
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

pub fn parse_unidata(
  txt: String,
  with fields_parser: fn(List(String)) -> Result(fields, Nil),
) -> Result(List(Record(fields)), ParserError) {
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
    Ok(fields) ->
      Ok(ParserState(
        Some(Record(codepoint_range:, fields:)),
        line: state.line + 1,
        txt: rest,
      ))
    Error(_) -> Error(InvalidFields(state.line))
  }
}

fn parse_unidata_loop(
  input state: ParserState(fields),
  output records: List(Record(fields)),
  with line_parser: fn(ParserState(fields)) ->
    Result(ParserState(fields), ParserError),
) -> Result(List(Record(fields)), ParserError) {
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
  use fields <- parse_unidata(txt)
  case fields {
    [name, ..] -> Ok(name)
    [] -> Error(Nil)
  }
}

pub fn parse_categories(
  txt: String,
) -> Result(List(Record(GeneralCategory)), ParserError) {
  use fields <- parse_unidata(txt)
  case fields {
    [cat, ..] -> category.from_abbreviation(cat)
    [] -> Error(Nil)
  }
}

pub fn assert_match_unidata(
  records: List(Record(fields)),
  codegen_match_record: fn(UtfCodepoint, fields) -> Bool,
) -> Nil {
  use record <- list.each(records)
  case record.codepoint_range {
    CodepointRange(from: start, to: end) -> {
      use cp <- list.each(list.range(
        string.utf_codepoint_to_int(start),
        string.utf_codepoint_to_int(end),
      ))
      let assert Ok(cp) = string.utf_codepoint(cp)
      assert codegen_match_record(cp, record.fields)
    }
    SingleCodepoint(cp) -> {
      assert codegen_match_record(cp, record.fields)
    }
    // NOTE handle surrogates manually in dedicated test assertions
    _ -> Nil
  }
}
