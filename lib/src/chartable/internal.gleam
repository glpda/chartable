import gleam/dict
import gleam/int
import gleam/list
import gleam/string

/// Converts a `FromCodepoint` table (`Dict(UtfCodepoint, List(String))`)
/// to a `String` for snapshot testing.
///
/// Sort the input to ensure deterministic output.
pub fn from_codepoint_table_to_string(dict) -> String {
  dict.to_list(dict)
  |> list.sort(fn(lhs, rhs) {
    int.compare(
      string.utf_codepoint_to_int(lhs.0),
      string.utf_codepoint_to_int(rhs.0),
    )
  })
  |> list.map(fn(key_value) {
    let #(codepoint, notations) = key_value
    let num = string.utf_codepoint_to_int(codepoint) |> int.to_string()
    let escapes =
      list.sort(notations, string.compare) |> string.join(with: ", ")

    num <> " (" <> string.from_utf_codepoints([codepoint]) <> "): " <> escapes
  })
  |> string.join(with: "\n")
}
