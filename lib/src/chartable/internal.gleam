import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Converts a `FromCodepoint` table (`Dict(UtfCodepoint, List(String))`)
/// to a `String` for snapshot testing.
///
/// Sort the input to ensure deterministic output.
pub fn from_codepoint_table_to_string(from_codepoint) -> String {
  dict.to_list(from_codepoint)
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

/// Asserts table consistency (`from_codepoint` match `to_codepoints`),
/// ignores names mapping to multiple codepoints wich are not included in
/// the `from_codepoint` table.
pub fn assert_table_consistency(from_codepoint, to_codepoints) -> Nil {
  dict.each(to_codepoints, fn(name, codepoints) {
    case codepoints {
      [codepoint] -> {
        assert dict.get(from_codepoint, codepoint)
          |> result.unwrap(or: [])
          |> list.contains(name)
      }
      _ -> Nil
    }
  })
  dict.each(from_codepoint, fn(codepoint, names) {
    assert list.all(names, fn(name) {
      dict.get(to_codepoints, name) == Ok([codepoint])
    })
  })
}

/// Parse an hexadecimal representation `String` to an `UtfCodepoint`
pub fn parse_codepoint(str: String) -> Result(UtfCodepoint, Nil) {
  int.base_parse(str, 16) |> result.try(string.utf_codepoint)
}

/// Converts a `UtfCodepoint` to an hexadecimal representation `String` padded
/// with zeros to have a minimum length of 4.
pub fn codepoint_to_hex(cp: UtfCodepoint) -> String {
  string.utf_codepoint_to_int(cp)
  |> int.to_base16()
  |> string.pad_start(to: 4, with: "0")
}

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
pub fn assert_notation_table_consistency(table: NotationTable) -> Nil {
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
pub fn notation_table_to_string(table: NotationTable) -> String {
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
