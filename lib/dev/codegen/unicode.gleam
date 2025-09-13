import chartable/internal
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/set
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
  RangeRecord(codepoint_range: codepoint.Range, data: data)
}

pub type AlternatingRecord(data) {
  AlternatingRecord(codepoint_range: codepoint.Range, even: data, odd: data)
  ContiguousRecord(codepoint_range: codepoint.Range, data: data)
}

fn concat_range_record(left: RangeRecord(data), right: RangeRecord(data)) {
  use <- bool.guard(when: left.data != right.data, return: Error(Nil))
  result.map(
    codepoint.range_union(left.codepoint_range, right.codepoint_range),
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

fn sort_range_records(records: List(RangeRecord(data))) {
  list.sort(records, fn(lhs, rhs) {
    codepoint.range_compare(lhs.codepoint_range, rhs.codepoint_range)
  })
}

pub fn range_records_to_string(
  records: List(RangeRecord(data)),
  data_to_string: fn(data) -> String,
) -> String {
  sort_range_records(records)
  |> list.map(fn(record) {
    let index = case codepoint.range_to_ints(record.codepoint_range) {
      #(start, end) if start == end -> {
        let hex = internal.int_to_hex(start)
        case string.utf_codepoint(start) {
          Ok(cp) -> hex <> " (" <> string.from_utf_codepoints([cp]) <> ")"
          Error(_) -> hex
        }
      }
      #(start, end) ->
        internal.int_to_hex(start) <> ".." <> internal.int_to_hex(end)
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
      case codepoint.range_to_ints(record.codepoint_range) {
        #(start, end) if start != end -> {
          let start = internal.int_to_hex(start)
          let end = internal.int_to_hex(end)
          let indentation = "    "
          // if ((0x3400 <= cp) && (cp <= 0x4DBF)) {
          //   return new Ok("CJK UNIFIED IDEOGRAPH-" + int_to_hex(cp));
          // }
          let if_in_range =
            "if ((0x" <> start <> " <= cp) && (cp <= 0x" <> end <> ")) {\n"
          let name =
            string.split(record.data, on: "*")
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
      case codepoint.range_to_ints(record.codepoint_range) {
        #(start, end) if start == end -> {
          let cp = internal.int_to_hex(start)
          // TODO assert name is (uppercase letter + space + dash)
          let name = string.replace(in: record.data, each: "*", with: cp)
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
      let #(start, end) = codepoint.range_to_ints(record.codepoint_range)
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
  scripts scripts: List(RangeRecord(String)),
  template template: String,
) -> String {
  let script_names =
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

  let script_ranges =
    sort_range_records(scripts)
    |> list.map(fn(record) {
      let pair = codepoint.range_to_ints(record.codepoint_range)
      let start = internal.int_to_hex(pair.0)
      let end = internal.int_to_hex(pair.1)
      // [[0x0000, 0x0040], "zyyy"]
      "[[0x" <> start <> ", 0x" <> end <> "], \"" <> record.data <> "\"]"
    })
    |> string.join(with: ",\n")

  string.replace(in: template, each: "/*{{script_names}}*/", with: script_names)
  |> string.replace(each: "/*{{script_ranges}}*/", with: script_ranges)
}

pub fn make_category_map(
  categories categories: List(AlternatingRecord(GeneralCategory)),
  template template: String,
) -> String {
  let categories =
    list.map(categories, fn(record) {
      let #(start, end) = codepoint.range_to_ints(record.codepoint_range)
      let start = internal.int_to_hex(start)
      let end = internal.int_to_hex(end)
      case record {
        AlternatingRecord(_, even:, odd:) -> {
          let even_name = category.to_short_name(even)
          let odd_name = category.to_short_name(odd)
          // [0x2C80, 0x2CE3, Lu, Ll] (Coptic)
          let range = "0x" <> start <> ", 0x" <> end
          "[" <> range <> ", " <> even_name <> ", " <> odd_name <> "]"
        }
        ContiguousRecord(_, data:) -> {
          let category_name = category.to_short_name(data)
          // [0x0000, 0x001F, "Cc"]
          "[0x" <> start <> ", 0x" <> end <> ", " <> category_name <> "]"
        }
      }
    })
    |> string.join(with: ",\n")
  string.replace(in: template, each: "/*{{categories}}*/", with: categories)
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

fn parse_alternating_records(
  txt: String,
  with fields_parser: fn(List(String)) -> Result(data, String),
) -> Result(List(AlternatingRecord(data)), ParserError) {
  use records <- parse_unidata(txt, parser: parse_range_record(_, fields_parser))
  use accumulator, previous_record <- list.fold(
    from: [],
    over: list.sort(records, fn(lhs, rhs) {
      codepoint.range_compare(lhs.codepoint_range, rhs.codepoint_range)
      |> order.negate
    }),
  )
  let RangeRecord(range_0, data_0) = previous_record
  case accumulator {
    [ContiguousRecord(range_1, data_1), ..next_records] if data_0 == data_1 ->
      case codepoint.range_union(range_0, range_1) {
        Error(_) -> [ContiguousRecord(range_0, data_0), ..accumulator]
        Ok(codepoint_range) -> [
          ContiguousRecord(codepoint_range, data_0),
          ..next_records
        ]
      }
    [
      ContiguousRecord(range_1, data_1),
      ContiguousRecord(range_2, data_2),
      ContiguousRecord(range_3, data_3),
      ..next_records
    ]
      if data_0 == data_2 && data_1 == data_3
    -> {
      // && data_0 != data_1
      let #(start_0, end_0) = codepoint.range_to_ints(range_0)
      let #(start_1, end_1) = codepoint.range_to_ints(range_1)
      let #(start_2, end_2) = codepoint.range_to_ints(range_2)
      let #(start_3, end_3) = codepoint.range_to_ints(range_3)
      case
        start_0 == end_0
        && start_1 == end_1
        && start_2 == end_2
        && start_3 == end_3
        && start_0 + 1 == start_1
        && start_0 + 2 == start_2
        && start_0 + 3 == start_3
      {
        False -> [ContiguousRecord(range_0, data_0), ..accumulator]
        True if start_0 % 2 == 0 -> {
          let assert Ok(codepoint_range) =
            codepoint.range_from_ints(start_0, end_3)
          [
            AlternatingRecord(codepoint_range:, even: data_0, odd: data_1),
            ..next_records
          ]
        }
        True -> {
          let assert Ok(codepoint_range) =
            codepoint.range_from_ints(start_0, end_3)
          [
            AlternatingRecord(codepoint_range:, even: data_1, odd: data_0),
            ..next_records
          ]
        }
      }
    }
    [ContiguousRecord(_, _), ..] -> [
      // if data_0 != data_1
      ContiguousRecord(range_0, data_0),
      ..accumulator
    ]

    [AlternatingRecord(range_1, even:, odd:), ..next_records] -> {
      let #(start_0, end_0) = codepoint.range_to_ints(range_0)
      let #(start_1, end_1) = codepoint.range_to_ints(range_1)
      let is_adjacent_single = start_0 == end_0 && start_0 + 1 != start_1
      let match_even = data_0 == even && start_0 % 2 == 0
      let match_odd = data_0 == odd && start_0 % 2 == 1
      case is_adjacent_single && { match_even || match_odd } {
        False -> [ContiguousRecord(range_0, data_0), ..accumulator]
        True -> {
          let assert Ok(codepoint_range) =
            codepoint.range_from_ints(start_0, end_1)
          [AlternatingRecord(codepoint_range:, even:, odd:), ..next_records]
        }
      }
    }
    [] -> [ContiguousRecord(range_0, data_0)]
  }
}

fn parse_range_records(
  txt: String,
  with fields_parser: fn(List(String)) -> Result(data, String),
) -> Result(List(RangeRecord(data)), ParserError) {
  use line <- parse_unidata(txt, reducer: concat_range_records)
  parse_range_record(line, fields_parser)
}

fn parse_range_record(
  line: String,
  with fields_parser: fn(List(String)) -> Result(data, String),
) -> Result(RangeRecord(data), String) {
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

fn parse_codepoint_range(str: String) -> Result(codepoint.Range, String) {
  case string.split_once(str, on: "..") {
    Ok(#(start, end)) -> {
      case internal.parse_codepoint(start), internal.parse_codepoint(end) {
        Ok(start), Ok(end) -> Ok(codepoint.range_from_codepoints(start, end))
        _, _ -> Error("Invalid Codepoint Range")
      }
    }
    Error(_) -> {
      case internal.parse_codepoint(str) {
        Ok(cp) -> Ok(codepoint.range_from_codepoints(cp, cp))
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
    [""] -> Error("Empty Name Field")
    [name, ..] -> Ok(name)
    [] -> Error("No Name Field")
  }
}

pub fn parse_alternating_categories(
  txt: String,
) -> Result(List(AlternatingRecord(GeneralCategory)), ParserError) {
  parse_alternating_records(txt, with: parse_category)
}

pub fn parse_categories(
  txt: String,
) -> Result(List(RangeRecord(GeneralCategory)), ParserError) {
  parse_range_records(txt, with: parse_category)
}

fn parse_category(data: List(String)) -> Result(GeneralCategory, String) {
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

pub fn parse_scripts(
  txt txt: String,
  property_value_aliases pva: List(PvaRecord),
) -> Result(List(RangeRecord(String)), ParserError) {
  let #(short_names, long_names) =
    list.fold(over: pva, from: #(set.new(), dict.new()), with: fn(acc, record) {
      case record {
        PvaRecord(property: "sc", short_name:, long_name:, ..) -> {
          let #(short_names, long_names) = acc
          let short_name = string.lowercase(short_name)
          let long_name = internal.comparable_property(long_name)
          #(
            set.insert(short_name, into: short_names),
            dict.insert(short_name, for: long_name, into: long_names),
          )
        }
        PvaRecord(..) -> acc
        CccRecord(..) -> acc
      }
    })

  use data <- parse_range_records(txt)
  case data {
    [script_name, ..] -> {
      let script_name = internal.comparable_property(script_name)
      use <- bool.guard(
        when: set.contains(script_name, in: short_names),
        return: Ok(script_name),
      )
      case dict.get(long_names, script_name) {
        Ok(short_name) -> Ok(short_name)
        Error(_) -> Error("Invalid Script Field")
      }
    }
    [] -> Error("No Script Field")
  }
}

// END

pub fn assert_match_range_records(
  records: List(RangeRecord(data)),
  codegen_match_record: fn(Codepoint, data) -> Bool,
) -> Nil {
  use record <- list.each(records)
  let #(start, end) = codepoint.range_to_ints(record.codepoint_range)
  use i <- list.each(list.range(start, end))
  let assert Ok(cp) = codepoint.from_int(i)
  assert codegen_match_record(cp, record.data)
}
