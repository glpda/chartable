import chartable
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import codegen/parser.{type ParserError}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import splitter

pub type Index {
  Index(Codepoint)
  Range(codepoint.Range)
}

pub type UnicodeDataRecord {
  UnicodeDataRecord(
    index: Index,
    name: Option(String),
    category: GeneralCategory,
  )
}

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

pub type NameAliasRecord {
  NameCorrection(codepoint: Codepoint, alias: String)
  NameControl(codepoint: Codepoint, alias: String)
  NameAlternate(codepoint: Codepoint, alias: String)
  NameFigment(codepoint: Codepoint, alias: String)
  NameAbbreviation(codepoint: Codepoint, alias: String)
}

pub type NameAliases {
  NameAliases(
    corrections: List(String),
    controls: List(String),
    alternates: List(String),
    figments: List(String),
    abbreviations: List(String),
  )
}

fn update_name_aliases(
  aliases: NameAliases,
  record: NameAliasRecord,
) -> NameAliases {
  case record {
    NameCorrection(_, alias:) ->
      NameAliases(..aliases, corrections: [alias, ..aliases.corrections])
    NameControl(_, alias:) ->
      NameAliases(..aliases, controls: [alias, ..aliases.controls])
    NameAlternate(_, alias:) ->
      NameAliases(..aliases, alternates: [alias, ..aliases.alternates])
    NameFigment(_, alias:) ->
      NameAliases(..aliases, figments: [alias, ..aliases.figments])
    NameAbbreviation(_, alias:) ->
      NameAliases(..aliases, abbreviations: [alias, ..aliases.abbreviations])
  }
}

pub type RangeRecord(data) {
  RangeRecord(codepoint_range: codepoint.Range, data: data)
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
        let hex = codepoint.int_to_hex(start)
        case string.utf_codepoint(start) {
          Ok(cp) -> hex <> " (" <> string.from_utf_codepoints([cp]) <> ")"
          Error(_) -> hex
        }
      }
      #(start, end) ->
        codepoint.int_to_hex(start) <> ".." <> codepoint.int_to_hex(end)
    }
    index <> ": " <> data_to_string(record.data)
  })
  |> string.join("\n")
}

pub type AlternatingRecord(data) {
  AlternatingRecord(codepoint_range: codepoint.Range, even: data, odd: data)
  ContiguousRecord(codepoint_range: codepoint.Range, data: data)
}

fn alternating_records(
  records: List(RangeRecord(data)),
) -> List(AlternatingRecord(data)) {
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
      let #(start, _) = codepoint.range_to_codepoints(range_0)
      let #(_, end) = codepoint.range_to_codepoints(range_3)
      let codepoint_range = codepoint.range_from_codepoints(start, end)
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
        True if start_0 % 2 == 0 -> [
          AlternatingRecord(codepoint_range:, even: data_0, odd: data_1),
          ..next_records
        ]
        True -> [
          AlternatingRecord(codepoint_range:, even: data_1, odd: data_0),
          ..next_records
        ]
      }
    }
    [ContiguousRecord(_, _), ..] -> [
      // if data_0 != data_1
      ContiguousRecord(range_0, data_0),
      ..accumulator
    ]

    [AlternatingRecord(range_1, even:, odd:), ..next_records] -> {
      let #(start_0, end_0) = codepoint.range_to_ints(range_0)
      let #(start_1, _) = codepoint.range_to_ints(range_1)
      let is_adjacent_single = start_0 == end_0 && start_0 + 1 == start_1
      let match_even = data_0 == even && start_0 % 2 == 0
      let match_odd = data_0 == odd && start_0 % 2 == 1
      case is_adjacent_single && { match_even || match_odd } {
        False -> [ContiguousRecord(range_0, data_0), ..accumulator]
        True -> {
          let #(start, _) = codepoint.range_to_codepoints(range_0)
          let #(_, end) = codepoint.range_to_codepoints(range_1)
          let codepoint_range = codepoint.range_from_codepoints(start, end)
          [AlternatingRecord(codepoint_range:, even:, odd:), ..next_records]
        }
      }
    }
    [] -> [ContiguousRecord(range_0, data_0)]
  }
}

// =============================================================================
// BEGIN CODE GENERATORS

fn js_string(string: String) -> String {
  "\"" <> string <> "\""
}

fn js_array(strings: List(String)) -> String {
  "[" <> string.join(strings, with: ", ") <> "]"
}

pub fn js_name_map(
  unidata unidata: List(UnicodeDataRecord),
  template template: String,
) {
  list.filter_map(unidata, fn(record) {
    use cp <- result.try(case record.index {
      Index(codepoint) -> Ok(codepoint.to_int(codepoint))
      Range(_) -> Error(Nil)
    })
    use name <- result.try(case record.name {
      // Some("") -> Error(Nil)
      Some("CJK UNIFIED IDEOGRAPH-" <> _) -> Error(Nil)
      Some("CJK COMPATIBILITY IDEOGRAPH-" <> _) -> Error(Nil)
      Some("EGYPTIAN HIEROGLYPH-" <> _) -> Error(Nil)
      Some("TANGUT IDEOGRAPH-" <> _) -> Error(Nil)
      Some("KHITAN SMALL SCRIPT CHARACTER-" <> _) -> Error(Nil)
      Some("NUSHU CHARACTER-" <> _) -> Error(Nil)
      // TODO assert name is (uppercase letter + space + dash)
      Some(name) -> Ok(name)
      _ -> Error(Nil)
    })
    let hex = codepoint.int_to_hex(cp)
    // [0x0020, "SPACE"]
    Ok(js_array(["0x" <> hex, js_string(name)]))
  })
  |> string.join(",\n")
  |> string.replace(in: template, each: "/*{{map_def}}*/")
}

pub fn js_name_alias_map(
  name_aliases name_aliases: Dict(Codepoint, NameAliases),
  template template: String,
) {
  let name_aliases =
    dict.to_list(name_aliases)
    |> list.sort(fn(lhs, rhs) { codepoint.compare(lhs.0, rhs.0) })
    |> list.map(fn(record) {
      let cp = "0x" <> codepoint.to_hex(record.0)
      let aliases = record.1
      let corrections = aliases.corrections |> list.map(js_string) |> js_array
      let controls = aliases.controls |> list.map(js_string) |> js_array
      let alternates = aliases.alternates |> list.map(js_string) |> js_array
      let figments = aliases.figments |> list.map(js_string) |> js_array
      let abbreviations =
        aliases.abbreviations |> list.map(js_string) |> js_array
      // [0x0000, [corrections], [controls], [alternates], [figments], [abbreviations]]
      js_array([cp, corrections, controls, alternates, figments, abbreviations])
    })
    |> string.join(with: ",\n")

  string.replace(in: template, each: "/*{{name_aliases}}*/", with: name_aliases)
}

pub fn js_block_map(
  property_value_aliases pva: List(PvaRecord),
  blocks blocks: List(RangeRecord(String)),
  template template: String,
) -> String {
  let aliases =
    list.fold(over: pva, from: dict.new(), with: fn(acc, record) {
      case record {
        PvaRecord(property: "blk", short_name:, long_name:, alt_names:) -> {
          let key = chartable.comparable_property(long_name)
          let value = case chartable.comparable_property(short_name) == key {
            True -> alt_names
            False -> [short_name, ..alt_names]
          }
          dict.insert(value, into: acc, for: key)
        }
        _ -> acc
      }
    })
  let blocks =
    list.map(blocks, fn(record) {
      let long_name = record.data
      let names =
        [
          long_name,
          ..result.unwrap(
            dict.get(aliases, chartable.comparable_property(long_name)),
            or: [],
          )
        ]
        |> list.map(fn(name) { "\"" <> name <> "\"" })
        |> string.join(with: ", ")
      let ints = codepoint.range_to_ints(record.codepoint_range)
      let start = codepoint.int_to_hex(ints.0)
      let end = codepoint.int_to_hex(ints.1)
      // [0x0000, 0x007F, "Basic Latin", "ASCII"]
      "[0x" <> start <> ", 0x" <> end <> ", " <> names <> "]"
    })
    |> string.join(with: ",\n")
  string.replace(in: template, each: "/*{{blocks}}*/", with: blocks)
}

pub fn js_script_map(
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
      let start = codepoint.int_to_hex(pair.0)
      let end = codepoint.int_to_hex(pair.1)
      // [[0x0000, 0x0040], "zyyy"]
      "[[0x" <> start <> ", 0x" <> end <> "], \"" <> record.data <> "\"]"
    })
    |> string.join(with: ",\n")

  string.replace(in: template, each: "/*{{script_names}}*/", with: script_names)
  |> string.replace(each: "/*{{script_ranges}}*/", with: script_ranges)
}

pub fn js_category_map(
  unidata unidata: List(UnicodeDataRecord),
  template template: String,
) {
  list.map(unidata, fn(record) {
    let codepoint_range = case record.index {
      Index(codepoint) -> codepoint.range_from_codepoints(codepoint, codepoint)
      Range(range) -> range
    }
    RangeRecord(codepoint_range:, data: record.category)
  })
  |> alternating_records
  |> list.map(fn(record) {
    let #(start, end) = codepoint.range_to_ints(record.codepoint_range)
    let start = codepoint.int_to_hex(start)
    let end = codepoint.int_to_hex(end)
    case record {
      AlternatingRecord(_, even:, odd:) -> {
        let even_name = category.to_short_name(even)
        let odd_name = category.to_short_name(odd)
        // [0x2C80, 0x2CE2, Lu, Ll] (Coptic)
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
  |> string.replace(in: template, each: "/*{{categories}}*/")
}

// END

// =============================================================================
// BEGIN UNIDATA PARSERS

type IndexKind {
  SingleCodepoint
  FirstCodepoint
  LastCodepoint
}

pub fn parse_unicode_data(
  txt: String,
) -> Result(List(UnicodeDataRecord), ParserError) {
  let semicolon = splitter.new([";"])
  let comma = splitter.new([","])
  let reducer = fn(state) {
    let #(range_start, records) = state
    case range_start {
      None -> Ok(list.reverse(records))
      Some(_) -> Error("Range Not Closed")
    }
  }
  use line, #(range_start, records) <- parser.parse_lines(
    txt:,
    init: #(None, []),
    comment: parser.LineStart([]),
    reducer:,
  )
  let #(index_field, _, rest) = splitter.split(semicolon, line)
  use codepoint <- result.try(
    codepoint.parse(index_field) |> result.replace_error("Invalid Codepoint"),
  )
  let #(name_field, _, rest) = splitter.split(semicolon, rest)
  let #(index_kind, name) = case name_field {
    "<" <> _ ->
      case splitter.split(comma, name_field).2 {
        " First>" -> #(FirstCodepoint, None)
        " Last>" -> #(LastCodepoint, None)
        _ -> #(SingleCodepoint, None)
      }
    // NOTE: could test if name is valid
    _ -> #(SingleCodepoint, Some(name_field))
  }
  let #(cat_field, _, _rest) = splitter.split(semicolon, rest)
  use category <- result.try(
    category.from_name(cat_field) |> result.replace_error("Invalid Category"),
  )
  // TODO parse other fields...
  let record = UnicodeDataRecord(index: Index(codepoint), name:, category:)
  case range_start, index_kind {
    None, SingleCodepoint -> Ok(#(None, [record, ..records]))
    None, FirstCodepoint -> Ok(#(Some(codepoint), records))
    None, LastCodepoint -> Error("Range Not Opened")
    Some(first), LastCodepoint -> {
      let index = Range(codepoint.range_from_codepoints(first, codepoint))
      let record = UnicodeDataRecord(index:, name:, category:)
      // NOTE: could test if range first & last record fields match
      Ok(#(None, [record, ..records]))
    }
    Some(_), _ -> Error("Range Not Closed")
  }
}

fn parse_records(
  // input txt unidata:
  txt txt: String,
  // line/record parser:
  parser parser: fn(String) -> Result(record, String),
  // process the resulting list of records (in reverse order):
  reducer reducer: fn(List(record)) -> output,
) -> Result(output, ParserError) {
  let reducer = fn(records) { Ok(reducer(records)) }
  let comment = parser.Anywhere(["#"])
  use line, records <- parser.parse_lines(txt:, init: [], comment:, reducer:)
  use record <- result.try(parser(line))
  Ok([record, ..records])
}

pub fn parse_property_value_aliases(
  txt: String,
) -> Result(List(PvaRecord), ParserError) {
  use line <- parse_records(txt, reducer: list.reverse)
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
  use line <- parse_records(txt, reducer: concat_range_records)
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
      use data <- result.try(fields_parser(other_fields))
      Ok(RangeRecord(codepoint_range:, data:))
    }
    _ -> Error("Missing Fields")
  }
}

fn parse_codepoint_range(str: String) -> Result(codepoint.Range, String) {
  case string.split_once(str, on: "..") {
    Ok(#(start, end)) -> {
      case codepoint.parse(start), codepoint.parse(end) {
        Ok(start), Ok(end) -> Ok(codepoint.range_from_codepoints(start, end))
        _, _ -> Error("Invalid Codepoint Range")
      }
    }
    Error(_) -> {
      case codepoint.parse(str) {
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

pub fn parse_name_aliases(
  txt: String,
) -> Result(Dict(Codepoint, NameAliases), ParserError) {
  let separator = splitter.new([";"])
  use records <- parse_records(txt:, parser: parse_name_alias(_, separator))
  use acc, record <- list.fold(over: records, from: dict.new())
  dict.upsert(in: acc, update: record.codepoint, with: fn(option) {
    case option {
      None -> update_name_aliases(NameAliases([], [], [], [], []), record)
      Some(aliases) -> update_name_aliases(aliases, record)
    }
  })
}

fn parse_name_alias(
  line: String,
  separator: splitter.Splitter,
) -> Result(NameAliasRecord, String) {
  let #(hex, _, rest) = splitter.split(separator, line)
  use codepoint <- result.try(
    string.trim(hex)
    |> codepoint.parse
    |> result.replace_error("Invalid Codepoint"),
  )
  let #(alias, _, rest) = splitter.split(separator, rest)
  let alias_type = splitter.split_before(separator, rest).0 |> string.trim
  case alias_type {
    "correction" -> Ok(NameCorrection(codepoint:, alias:))
    "control" -> Ok(NameControl(codepoint:, alias:))
    "alternate" -> Ok(NameAlternate(codepoint:, alias:))
    "figment" -> Ok(NameFigment(codepoint:, alias:))
    "abbreviation" -> Ok(NameAbbreviation(codepoint:, alias:))
    _ -> Error("Invalid Name Alias Type")
  }
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
          let long_name = chartable.comparable_property(long_name)
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
      let script_name = chartable.comparable_property(script_name)
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
