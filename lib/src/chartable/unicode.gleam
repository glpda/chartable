import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/data
import gleam/dict
import gleam/int
import gleam/result
import gleam/string
import splitter.{split}

pub type UnicodeData {
  UnicodeData(name: String, general_category: GeneralCategory)
}

pub fn make_unicode_data() {
  parse_unicode_data(data.txt)
}

/// https://www.unicode.org/reports/tr44/#UnicodeData.txt
///
fn parse_unicode_data(txt: String) {
  let line_end = splitter.new(["\n"])
  let table = dict.new()

  use txt <- parse_unicode_data_loop(input: txt, table:)
  let #(line, _, rest) = split(line_end, txt)
  case string.split(line, on: ";") {
    [
      codepoint,
      name,
      category_abbreviation,
      _canonical_combining_class,
      _bidi_class,
      _decomposition,
      _nv_decimal,
      _nv_digit,
      _nv_numeric,
      _bidi_mirrored,
      _unicode_1_name,
      _iso_comment,
      _simple_uppercase_mapping,
      _simple_lowercase_mapping,
      _simple_titlecase_mapping,
    ] ->
      {
        let codepoint =
          int.base_parse(codepoint, 16) |> result.try(string.utf_codepoint)
        use codepoint <- result.try(codepoint)

        use general_category <- result.try(category.from_abbreviation(
          category_abbreviation,
        ))

        let record = UnicodeData(name:, general_category:)
        Ok(#(codepoint, record, rest))
      }
      |> result.replace_error(rest)
    _ -> Error(rest)
  }
}

fn parse_unicode_data_loop(
  input str: String,
  table table: dict.Dict(UtfCodepoint, record),
  with line_parser: fn(String) ->
    Result(#(UtfCodepoint, record, String), String),
) -> dict.Dict(UtfCodepoint, record) {
  case str {
    "" -> table
    _ ->
      case line_parser(str) {
        Ok(#(codepoint, record, rest)) -> {
          let table = dict.insert(into: table, for: codepoint, insert: record)
          parse_unicode_data_loop(rest, table:, with: line_parser)
        }
        Error(rest) -> parse_unicode_data_loop(rest, table:, with: line_parser)
      }
  }
}
