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

/// Records for "`PropertyValueAliases.txt`"
pub type PvaRecord {
  // sc        ; Zinh        ; Inherited  ; Qaai
  // {property}; {short_name}; {long_name}; {alt_names}...
  PvaRecord(
    short_name: String,
    long_name: String,
    property: String,
    alt_names: List(String),
  )
  // ccc;         0; NR          ; Not_Reordered
  // ccc; {numeric}; {short_name}; {long_name}
  CccRecord(short_name: String, long_name: String, numeric: Int)
}

pub type RangeRecord(data) {
  RangeRecord(codepoint_range: CodepointRange, data: data)
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
    HighSurrogates -> #(0xD800, 0xDBFF)
    HighStandardSurrogates -> #(0xD800, 0xDB7F)
    HighPrivateUseSurrogates -> #(0xDB80, 0xDBFF)
    LowSurrogates -> #(0xDC00, 0xDFFF)
  }
}

pub fn pair_to_codepoint_range(start: Int, end: Int) {
  case start, end {
    0xD800, 0xDFFF -> Ok(AllSurrogates)
    0xD800, 0xDBFF -> Ok(HighSurrogates)
    0xD800, 0xDB7F -> Ok(HighStandardSurrogates)
    0xDB80, 0xDBFF -> Ok(HighPrivateUseSurrogates)
    0xDC00, 0xDFFF -> Ok(LowSurrogates)
    _, _ if start < end -> {
      case string.utf_codepoint(start), string.utf_codepoint(end) {
        Ok(start), Ok(end) -> Ok(CodepointRange(from: start, to: end))
        _, _ -> Error(Nil)
      }
    }
    _, _ if start == end ->
      string.utf_codepoint(start) |> result.map(SingleCodepoint)
    _, _ -> Error(Nil)
  }
}

fn concat_codepoint_range(left: CodepointRange, right: CodepointRange) {
  let #(left_start, left_end) = codepoint_range_to_pair(left)
  let #(right_start, right_end) = codepoint_range_to_pair(right)
  // case left, right:
  //   HighSurrogates, LowSurrogates -> AllSurrogates
  //   HighStandardSurrogates, HighPrivateUseSurrogates -> HighSurrogates
  case left_end + 1 == right_start, right_end + 1 == left_start {
    True, _ -> pair_to_codepoint_range(left_start, right_end)
    _, True -> pair_to_codepoint_range(right_start, left_end)
    False, False -> Error(Nil)
  }
}

fn concat_range_record(left: RangeRecord(data), right: RangeRecord(data)) {
  use <- bool.guard(when: left.data != right.data, return: Error(Nil))
  result.map(
    concat_codepoint_range(left.codepoint_range, right.codepoint_range),
    RangeRecord(_, left.data),
  )
}

fn concat_range_records(
  records: List(RangeRecord(data)),
) -> List(RangeRecord(data)) {
  use accumulator, previous_record <- list.fold(over: records, from: [])
  case accumulator {
    [current_record, ..next_records] -> {
      case concat_range_record(previous_record, current_record) {
        Error(_) -> [previous_record, current_record, ..next_records]
        Ok(concat_record) -> [concat_record, ..next_records]
      }
    }
    [] -> [previous_record]
  }
}

pub fn range_records_to_string(
  records: List(RangeRecord(data)),
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

// =============================================================================
// BEGIN CODE GENERATORS

pub fn make_name_map(
  names names: List(RangeRecord(String)),
  template template: String,
) -> String {
  let if_ranges =
    list.filter_map(names, fn(record) {
      case record {
        RangeRecord(CodepointRange(from: start, to: end), name) if name != "" -> {
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
        RangeRecord(SingleCodepoint(cp), name) if name != "" -> {
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
  blocks blocks: List(RangeRecord(String)),
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

pub fn make_script_map(
  property_value_aliases pva: List(PvaRecord),
  template template: String,
) {
  let scripts =
    list.filter_map(pva, fn(record) {
      case record {
        PvaRecord(property: "sc", short_name:, long_name:, ..) -> {
          let short_name = string.lowercase(short_name)
          // ["zinh", "Inherited"]
          Ok("[\"" <> short_name <> "\", \"" <> long_name <> "\"]")
        }
        _ -> Error(Nil)
      }
    })
    |> string.join(with: ",\n")
  string.replace(in: template, each: "/*{{scripts}}*/", with: scripts)
}

// END

// =============================================================================
// BEGIN UNIDATA PARSERS

type ParserState {
  ParserState(line: Int, txt: String)
}

pub type ParserError {
  ParserError(line: Int, error: String)
}

fn parse_unidata(
  // input txt unidata:
  txt txt: String,
  // line/record parser:
  parser parser: fn(String) -> Result(record, String),
  // process the resulting list of records (in reverse order):
  reducer reducer: fn(List(record)) -> output,
) -> Result(output, ParserError) {
  let line_end = splitter.new(["\n"])
  let comment = splitter.new(["#"])

  let parser_state = ParserState(line: 0, txt:)
  use txt <- parse_unidata_loop(input: parser_state, output: [], reducer:)
  let #(line, _, rest) = splitter.split(line_end, txt)
  let #(line, _, _) = splitter.split(comment, line)
  let line = string.trim(line)
  use <- bool.guard(when: string.is_empty(line), return: Ok(#(None, rest)))
  parser(line) |> result.map(fn(record) { #(Some(record), rest) })
}

fn parse_unidata_loop(
  input state: ParserState,
  output records: List(record),
  parser parser: fn(String) -> Result(#(Option(record), String), String),
  reducer reducer: fn(List(record)) -> output,
) -> Result(output, ParserError) {
  case state.txt {
    "" -> Ok(reducer(records))
    _ ->
      case parser(state.txt) {
        Ok(#(Some(record), rest)) -> {
          let output = [record, ..records]
          let state = ParserState(line: state.line + 1, txt: rest)
          parse_unidata_loop(state, output:, parser:, reducer:)
        }
        Ok(#(None, rest)) -> {
          let state = ParserState(line: state.line + 1, txt: rest)
          parse_unidata_loop(state, output: records, parser:, reducer:)
        }
        Error(error) -> Error(ParserError(line: state.line, error:))
      }
  }
}

pub fn parse_property_value_aliases(
  txt: String,
) -> Result(List(PvaRecord), ParserError) {
  use line <- parse_unidata(txt, reducer: list.reverse)
  let fields = string.split(line, on: ";") |> list.map(string.trim)
  case fields {
    // ccc;       0; NR        ; Not_Reordered
    ["ccc", numeric, short_name, long_name, ..] ->
      case int.parse(numeric) {
        Ok(numeric) -> Ok(CccRecord(numeric:, short_name:, long_name:))
        Error(_) ->
          Error("Canonical_Combining_Class (ccc): non-numeric second field")
      }
    // sc    ; Zinh      ; Inherited; Qaai
    [property, short_name, long_name, ..alt_names] ->
      Ok(PvaRecord(property:, short_name:, long_name:, alt_names:))
    _ -> Error("Missing Fields")
  }
}

fn parse_range_records(
  txt: String,
  with fields_parser: fn(List(String)) -> Result(data, String),
) -> Result(List(RangeRecord(data)), ParserError) {
  use line: String <- parse_unidata(txt, reducer: concat_range_records)
  let fields = string.split(line, on: ";") |> list.map(string.trim)
  case fields {
    [first_field, ..other_fields] -> {
      use codepoint_range <- result.try(parse_codepoint_range(first_field))
      use data <- result.map(fields_parser(other_fields))
      RangeRecord(codepoint_range:, data:)
    }
    _ -> Error("Missing Fields")
  }
}

fn parse_codepoint_range(str: String) -> Result(CodepointRange, String) {
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
        _, _, _ -> Error("Invalid Codepoint Range")
      }
    }
    Error(_) -> {
      case internal.parse_codepoint(str) {
        Ok(codepoint) -> Ok(SingleCodepoint(codepoint))
        Error(_) -> Error("Invalid Codepoint")
      }
    }
  }
}

pub fn parse_names(
  txt: String,
) -> Result(List(RangeRecord(String)), ParserError) {
  use data <- parse_range_records(txt)
  case data {
    [name, ..] -> Ok(name)
    [] -> Error("No Name Field")
  }
}

pub fn parse_categories(
  txt: String,
) -> Result(List(RangeRecord(GeneralCategory)), ParserError) {
  use data <- parse_range_records(txt)
  case data {
    [cat, ..] ->
      category.from_name(cat) |> result.replace_error("Invalid Category")
    [] -> Error("No Category Field")
  }
}

pub fn parse_blocks(
  txt: String,
) -> Result(List(RangeRecord(String)), ParserError) {
  use data <- parse_range_records(txt)
  case data {
    [block_name, ..] -> Ok(block_name)
    [] -> Error("No Block Field")
  }
}

// END

pub fn assert_match_range_records(
  records: List(RangeRecord(data)),
  codegen_match_record: fn(Int, data) -> Bool,
) -> Nil {
  use record <- list.each(records)
  let #(start, end) = codepoint_range_to_pair(record.codepoint_range)
  use cp <- list.each(list.range(start, end))
  assert codegen_match_record(cp, record.data)
}
