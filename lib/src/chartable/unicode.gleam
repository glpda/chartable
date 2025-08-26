import chartable/internal
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
/// assert string.utf_codepoint(0x661F)
///   |> result.try(unicode.name_from_codepoint)
///   == Ok("CJK UNIFIED IDEOGRAPH-661F")
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
/// assert unicode.name_from_int(0x661F) == Ok("CJK UNIFIED IDEOGRAPH-661F")
/// ```
///
@external(javascript, "./unicode/name_map.mjs", "get_name")
pub fn name_from_int(cp: Int) -> Result(String, Nil)

/// Get the list of all Unicode blocks' name.
@external(javascript, "./unicode/block_map.mjs", "get_list")
pub fn blocks() -> List(String)

/// Get the name of the Unicode block to which a `UtfCodepoint` belongs.
/// Returns `"No_Block"` if the code point is not assigned to any blocks.
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x0041)
///   |> result.map(unicode.block_from_codepoint)
///   == Ok("Basic Latin")
///
/// assert string.utf_codepoint(0x22C6)
///   |> result.map(unicode.block_from_codepoint)
///   == Ok("Mathematical Operators")
///
/// assert string.utf_codepoint(0x661F)
///   |> result.map(unicode.block_from_codepoint)
///   == Ok("CJK Unified Ideographs")
/// ```
///
pub fn block_from_codepoint(cp: UtfCodepoint) -> String {
  codepoint_to_block_ffi(string.utf_codepoint_to_int(cp))
}

/// Get the name of the Unicode block to which a code point belongs.
/// Returns `Ok("No_Block")` if the code point is not assigned to any blocks,
/// and `Error(Nil)` if the integer does not represent a valid code point.
///
/// ## Examples
///
/// ```gleam
/// assert unicode.block_from_int(-100) == Error(Nil)
/// assert unicode.block_from_int(0x0041) == Ok("Basic Latin")
/// assert unicode.block_from_int(0x22C6) == Ok("Mathematical Operators")
/// assert unicode.block_from_int(0x661F) == Ok("CJK Unified Ideographs")
/// ```
///
pub fn block_from_int(cp: Int) -> Result(String, Nil) {
  case cp {
    cp if cp < 0 || 0x10FFFF < cp -> Error(Nil)
    cp if 0 < cp && cp < 0x007F -> Ok("Basic Latin")
    cp -> Ok(codepoint_to_block_ffi(cp))
  }
}

@external(javascript, "./unicode/block_map.mjs", "codepoint_to_block")
fn codepoint_to_block_ffi(cp: Int) -> String

/// Get the code point range `#(start, end)` of a Unicode block,
/// block's name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// assert unicode.block_to_pair("Basic_Latin") == Ok(#(0x0000, 0x007F))
/// assert unicode.block_to_pair("isHighSurrogates") == Ok(#(0xD800, 0xDB7F))
/// assert unicode.block_to_pair("Lucy") == Error(Nil)
/// ```
///
pub fn block_to_pair(block_name: String) -> Result(#(Int, Int), Nil) {
  let comparable_property = internal.comparable_property(block_name)
  case comparable_property {
    "basiclatin" -> Ok(#(0x0000, 0x007F))
    "noblock" -> Error(Nil)
    _ -> block_to_pair_ffi(comparable_property)
  }
}

@external(javascript, "./unicode/block_map.mjs", "block_to_codepoint_pair")
fn block_to_pair_ffi(block_name: String) -> Result(#(Int, Int), Nil)

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
pub fn category_from_codepoint(cp: UtfCodepoint) -> GeneralCategory

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
