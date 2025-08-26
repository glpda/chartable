import gleam/int
import gleam/result
import gleam/string
import gleam/string_tree

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

/// Converts to a loose `String` for catalog/enumeration property matching
///
/// Rule [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3):
/// ignore case, whitespaces, underscores, hyphens, and initial prefix "is"
pub fn comparable_property(str: String) -> String {
  case string.lowercase(str) {
    "is" -> "is"
    "is" <> str -> str
    str -> str
  }
  |> string_tree.from_string()
  |> string_tree.replace(each: " ", with: "")
  |> string_tree.replace(each: "-", with: "")
  |> string_tree.replace(each: "_", with: "")
  |> string_tree.to_string()
}
