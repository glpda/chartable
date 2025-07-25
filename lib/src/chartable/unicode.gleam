import gleam/string

/// Get the unicode "Name" property of a code point
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x0041)
///   |> result.try(unicode.name_from_codepoint)
///   == Ok("LATIN CAPITAL LETTER A")
///
/// assert string.utf_codepoint(0x03A2)
///   |> result.try(unicode.name_from_codepoint)
///   == Error(Nil)
///
/// assert string.utf_codepoint(0x22C6)
///   |> result.try(unicode.name_from_codepoint)
///   == Ok("STAR OPERATOR")
///
/// assert string.utf_codepoint(0x4E55)
///   |> result.try(unicode.name_from_codepoint)
///   == Ok("CJK UNIFIED IDEOGRAPH-4E55")
/// ```
///
pub fn name_from_codepoint(cp: UtfCodepoint) -> Result(String, Nil) {
  name_from_int(string.utf_codepoint_to_int(cp))
}

/// Get the unicode "Name" property of a code point
///
/// ## Examples
///
/// ```gleam
/// assert unicode.name_from_int(0x0041) == Ok("LATIN CAPITAL LETTER A")
///
/// assert unicode.name_from_int(0x03A2) == Error(Nil)
///
/// assert unicode.name_from_int(0x22C6) == Ok("STAR OPERATOR")
///
/// assert unicode.name_from_int(0x4E55) == Ok("CJK UNIFIED IDEOGRAPH-4E55")
/// ```
///
@external(javascript, "./unicode/name_map.mjs", "get_name")
pub fn name_from_int(cp: Int) -> Result(String, Nil)
