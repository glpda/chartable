import chartable/unicode/category.{type GeneralCategory}
import gleam/string

/// Get the Unicode "Name" property of a code point. Returns an `Error` if the
/// character does not have a standard name (control or unassigned characters).
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

/// Get the Unicode "Name" property of a code point. Returns an `Error` if the
/// integer does not represent a valid code point, or if the character does not
/// have a standard name (is not assigned or is a control character).
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

/// Get the Unicode [`GeneralCategory`](unicode/category.html#GeneralCategory)
/// property of a code point.
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x0041)
///   |> result.map(unicode.category_from_codepoint)
///   == Ok(category.LetterUppercase)
///
/// assert string.utf_codepoint(0x0032)
///   |> result.map(unicode.category_from_codepoint)
///   == Ok(category.NumberDecimal)
///
/// assert string.utf_codepoint(0x0024)
///   |> result.map(unicode.category_from_codepoint)
///   == Ok(category.SymbolCurrency)
///
/// assert string.utf_codepoint(0x0007)
///   |> result.map(unicode.category_from_codepoint)
///   == Ok(category.Control)
/// ```
///
@external(javascript, "./unicode/category_regexp.mjs", "get_category")
pub fn category_from_codepoint(cp: UtfCodepoint) -> GeneralCategory {
  string.utf_codepoint_to_int(cp) |> category_from_int()
}

/// Get the Unicode [`GeneralCategory`](unicode/category.html#GeneralCategory)
/// property of a code point. Returns an `Unassigned` category if the integer
/// does not represent a valid codepoint.
///
/// ## Examples
///
/// ```gleam
/// import chartable/unicode
/// import chartable/unicode/category
///
/// assert unicode.category_from_int(0x0041) == category.LetterUppercase
/// assert unicode.category_from_int(0x0032) == category.NumberDecimal
/// assert unicode.category_from_int(0x0024) == category.SymbolCurrency
/// assert unicode.category_from_int(0x0007) == category.Control
/// assert unicode.category_from_int(0x00AD) == category.Format
/// assert unicode.category_from_int(0xD877) == category.Surrogate
/// assert unicode.category_from_int(0xE777) == category.PrivateUse
/// assert unicode.category_from_int(0x03A2) == category.Unassigned
/// ```
///
pub fn category_from_int(cp: Int) -> GeneralCategory {
  case string.utf_codepoint(cp) {
    Ok(cp) -> category_from_codepoint(cp)
    Error(_) if 0xD800 <= cp && cp <= 0xDFFF -> category.Surrogate
    Error(_) -> category.Unassigned
  }
}
