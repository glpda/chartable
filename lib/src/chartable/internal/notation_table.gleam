import chartable/internal
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// A pair of dictionaries mapping `String` notations (escape sequences) to
/// [grapheme](https://en.wikipedia.org/wiki/Grapheme) cluster,
/// a grapheme can have multiple `String` notations.
pub type NotationTable {
  NotationTable(
    grapheme_to_notations: Dict(String, List(String)),
    notation_to_grapheme: Dict(String, String),
  )
}

/// Asserts notation table consistency (`grapheme_to_notations` match
/// `notation_to_grapheme`), ignores notations mapping to multiple codepoints
/// wich are not included in the `grapheme_to_notations` table.
pub fn assert_consistency(table: NotationTable) -> Nil {
  dict.each(table.grapheme_to_notations, fn(grapheme, notations) {
    assert list.all(notations, fn(notation) {
      dict.get(table.notation_to_grapheme, notation) == Ok(grapheme)
    })
  })
  dict.each(table.notation_to_grapheme, fn(notation, grapheme) {
    assert dict.get(table.grapheme_to_notations, grapheme)
      |> result.unwrap(or: [])
      |> list.contains(notation)
  })
}

/// Converts the `grapheme_to_notations` dictionary of a `NotationTable`
/// to a `String` for snapshot testing.
///
/// Sort the input to ensure deterministic output.
pub fn to_string(table: NotationTable) -> String {
  dict.to_list(table.grapheme_to_notations)
  |> list.sort(fn(lhs, rhs) { string.compare(lhs.0, rhs.0) })
  |> list.map(fn(key_value) {
    let #(grapheme, notations) = key_value
    let codepoints =
      string.to_utf_codepoints(grapheme)
      |> list.map(internal.codepoint_to_hex)
      |> string.join("-")
    let escapes =
      list.sort(notations, string.compare) |> string.join(with: ", ")

    codepoints <> " (" <> grapheme <> "): " <> escapes
  })
  |> string.join(with: "\n")
}

pub fn update(
  table: NotationTable,
  grapheme grapheme: String,
  notation notation: String,
) -> NotationTable {
  let grapheme_to_notations =
    dict.upsert(grapheme, in: table.grapheme_to_notations, with: fn(option) {
      case option {
        None -> [notation]
        Some(list) -> [notation, ..list]
      }
    })

  let notation_to_grapheme =
    dict.insert(grapheme, into: table.notation_to_grapheme, for: notation)

  NotationTable(grapheme_to_notations:, notation_to_grapheme:)
}

/// Builds a `NotationTable` from a `grapheme_to_notations` dictionary.
pub fn complement_grapheme_to_notations(
  dict: Dict(String, List(String)),
) -> NotationTable {
  dict.fold(
    over: dict,
    from: dict.new(),
    with: fn(notation_to_grapheme, grapheme, notations) {
      list.fold(
        over: notations,
        from: notation_to_grapheme,
        with: fn(notation_to_grapheme, notation) {
          dict.insert(grapheme, into: notation_to_grapheme, for: notation)
        },
      )
    },
  )
  |> NotationTable(grapheme_to_notations: dict)
}

/// Builds a `NotationTable` from a `notation_to_grapheme` dictionary.
pub fn complement_notation_to_grapheme(
  dict: Dict(String, String),
) -> NotationTable {
  dict.fold(
    over: dict,
    from: dict.new(),
    with: fn(grapheme_to_notations, notation, grapheme) {
      dict.upsert(grapheme, in: grapheme_to_notations, with: fn(option) {
        case option {
          None -> [notation]
          Some(list) -> [notation, ..list]
        }
      })
    },
  )
  |> NotationTable(notation_to_grapheme: dict)
}

pub fn parse_notation_to_grapheme_json(
  json: String,
) -> Result(NotationTable, json.DecodeError) {
  let decoder = decode.dict(decode.string, decode.string)

  json.parse(from: json, using: decoder)
  |> result.map(complement_notation_to_grapheme)
}

pub fn make_javascript_map(
  table table: NotationTable,
  template template: String,
  data_source data_source: String,
) -> String {
  let grapheme_to_notations =
    dict.to_list(table.grapheme_to_notations)
    |> list.sort(fn(lhs, rhs) { string.compare(lhs.0, rhs.0) })
    |> list.map(fn(key_value) {
      let #(grapheme, notations) = key_value
      let codepoints = grapheme_to_codepoints(grapheme)
      let notations =
        list.sort(notations, string.compare)
        |> list.map(fn(notation) { "\"" <> notation <> "\"" })
        |> string.join(with: ", ")

      "[\"" <> codepoints <> "\", [" <> notations <> "]]"
    })
    |> string.join(",\n")

  let notation_to_grapheme =
    dict.to_list(table.notation_to_grapheme)
    |> list.sort(fn(lhs, rhs) { string.compare(lhs.0, rhs.0) })
    |> list.map(fn(key_value) {
      let #(notation, grapheme) = key_value
      let codepoints = grapheme_to_codepoints(grapheme)
      "[\"" <> notation <> "\", \"" <> codepoints <> "\"]"
    })
    |> string.join(",\n")

  string.replace(in: template, each: "{{data_source}}", with: data_source)
  |> string.replace(
    each: "/*{{grapheme_to_notations}}*/",
    with: grapheme_to_notations,
  )
  |> string.replace(
    each: "/*{{notation_to_grapheme}}*/",
    with: notation_to_grapheme,
  )
}

fn grapheme_to_codepoints(grapheme: String) -> String {
  string.to_utf_codepoints(grapheme)
  |> list.map(fn(cp) { "\\u{" <> internal.codepoint_to_hex(cp) <> "}" })
  |> string.concat()
}
