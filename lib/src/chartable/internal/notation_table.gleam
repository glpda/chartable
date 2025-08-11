import chartable/internal
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// A pair of dictionaries mapping `String` notations to `UtfCodepoint`s,
/// a `UtfCodepoint` can have multiple `String` notations and a `String`
/// notations can map to a graphene cluster `List(UtfCodepoint)`.
pub type NotationTable {
  // NOTE maybe `String` would be better than `List(UtfCodepoint)`
  NotationTable(
    codepoint_to_notations: Dict(UtfCodepoint, List(String)),
    notation_to_codepoints: Dict(String, List(UtfCodepoint)),
  )
}

/// Asserts notation table consistency (`codepoint_to_notations` match
/// `notation_to_codepoints`), ignores notations mapping to multiple codepoints
/// wich are not included in the `codepoint_to_notations` table.
pub fn assert_consistency(table: NotationTable) -> Nil {
  dict.each(table.codepoint_to_notations, fn(codepoint, notations) {
    assert list.all(notations, fn(notation) {
      dict.get(table.notation_to_codepoints, notation) == Ok([codepoint])
    })
  })
  dict.each(table.notation_to_codepoints, fn(notation, codepoints) {
    case codepoints {
      [codepoint] -> {
        assert dict.get(table.codepoint_to_notations, codepoint)
          |> result.unwrap(or: [])
          |> list.contains(notation)
      }
      _ -> Nil
    }
  })
}

/// Converts the `codepoint_to_notations` dictionary of a `NotationTable`
/// to a `String` for snapshot testing.
///
/// Sort the input to ensure deterministic output.
pub fn to_string(table: NotationTable) -> String {
  dict.to_list(table.codepoint_to_notations)
  |> list.sort(fn(lhs, rhs) {
    int.compare(
      string.utf_codepoint_to_int(lhs.0),
      string.utf_codepoint_to_int(rhs.0),
    )
  })
  |> list.map(fn(key_value) {
    let #(codepoint, notations) = key_value
    let num =
      string.utf_codepoint_to_int(codepoint)
      |> int.to_base16()
      |> string.pad_start(to: 4, with: "0")
    let escapes =
      list.sort(notations, string.compare) |> string.join(with: ", ")

    num <> " (" <> string.from_utf_codepoints([codepoint]) <> "): " <> escapes
  })
  |> string.join(with: "\n")
}

/// Builds a `NotationTable` from a `codepoint_to_notations` dictionary.
pub fn complement_codepoint_to_notations(dict: Dict(UtfCodepoint, List(String))) {
  dict.fold(
    over: dict,
    from: dict.new(),
    with: fn(notation_to_codepoints, codepoint, notations) {
      list.fold(
        over: notations,
        from: notation_to_codepoints,
        with: fn(notation_to_codepoints, notation) {
          dict.insert(into: notation_to_codepoints, for: notation, insert: [
            codepoint,
          ])
        },
      )
    },
  )
  |> NotationTable(codepoint_to_notations: dict)
}

/// Builds a `NotationTable` from a `notation_to_codepoints` dictionary.
pub fn complement_notation_to_codepoint(
  dict: Dict(String, List(UtfCodepoint)),
) -> NotationTable {
  dict.fold(
    over: dict,
    from: dict.new(),
    with: fn(codepoint_to_notations, notation, codepoints) {
      case codepoints {
        [codepoint] ->
          dict.upsert(codepoint, in: codepoint_to_notations, with: fn(option) {
            case option {
              None -> [notation]
              Some(list) -> [notation, ..list]
            }
          })
        _ -> codepoint_to_notations
      }
    },
  )
  |> NotationTable(notation_to_codepoints: dict)
}

pub fn parse_notation_to_codepoints_json(
  json: String,
) -> Result(NotationTable, json.DecodeError) {
  let codepoints_decoder = decode.string |> decode.map(string.to_utf_codepoints)
  let decoder = decode.dict(decode.string, codepoints_decoder)

  json.parse(from: json, using: decoder)
  |> result.map(complement_notation_to_codepoint)
}

pub fn make_javascript_map(
  table table: NotationTable,
  template template: String,
  data_source data_source: String,
) -> String {
  let codepoint_to_notations =
    dict.to_list(table.codepoint_to_notations)
    |> list.sort(fn(lhs, rhs) {
      int.compare(
        string.utf_codepoint_to_int(lhs.0),
        string.utf_codepoint_to_int(rhs.0),
      )
    })
    |> list.map(fn(key_value) {
      let #(cp, notations) = key_value
      let cp = internal.codepoint_to_hex(cp)
      let notations =
        list.sort(notations, string.compare)
        |> list.map(fn(notation) { "\"" <> notation <> "\"" })
        |> string.join(with: ", ")

      "[0x" <> cp <> ", [" <> notations <> "]]"
    })
    |> string.join(",\n")

  let notation_to_codepoints =
    dict.to_list(table.notation_to_codepoints)
    |> list.sort(fn(lhs, rhs) { string.compare(lhs.0, rhs.0) })
    |> list.map(fn(key_value) {
      let #(notation, codepoints) = key_value
      let codepoints =
        list.map(codepoints, fn(cp) { "0x" <> internal.codepoint_to_hex(cp) })
        |> string.join(", ")
      "[\"" <> notation <> "\", [" <> codepoints <> "]]"
    })
    |> string.join(",\n")

  string.replace(in: template, each: "{{data_source}}", with: data_source)
  |> string.replace(
    each: "/*{{codepoint_to_notations}}*/",
    with: codepoint_to_notations,
  )
  |> string.replace(
    each: "/*{{notation_to_codepoints}}*/",
    with: notation_to_codepoints,
  )
}
