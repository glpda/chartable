import gleam/int
import gleam/result
import gleam/string

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
