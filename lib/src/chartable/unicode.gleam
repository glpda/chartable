import chartable/internal
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import gleam/result

/// Get the Unicode "Name" property of a code point.
///
/// Returns an `Error` if the character does not have a standard name
/// (control or unassigned characters).
///
/// ## Examples
///
/// ```gleam
/// use cp <- result.map(codepoint.from_int(0x661F))
/// assert unicode.name_from_codepoint(cp) == Ok("CJK UNIFIED IDEOGRAPH-661F")
/// ```
///
pub fn name_from_codepoint(cp: Codepoint) -> Result(String, Nil) {
  codepoint_to_name_ffi(codepoint.to_int(cp))
}

@external(javascript, "./unicode/name_map.mjs", "get_name")
fn codepoint_to_name_ffi(cp: Int) -> Result(String, Nil)

/// Get the list of all Unicode blocks' name.
@external(javascript, "./unicode/block_map.mjs", "get_list")
pub fn blocks() -> List(String)

/// Get the name of the Unicode block to which a `Codepoint` belongs.
///
/// Returns `"No_Block"` if the code point is not assigned to any blocks.
///
/// ## Examples
///
/// ```gleam
/// use cp <- result.map(codepoint.from_int(0x661F))
/// assert unicode.block_from_codepoint(cp) == "CJK Unified Ideographs"
/// ```
///
pub fn block_from_codepoint(cp: Codepoint) -> String {
  codepoint_to_block_ffi(codepoint.to_int(cp))
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
/// let assert Ok(ascii) = unicode.block_to_range("Basic Latin")
/// assert codepoint.range_to_ints(ascii) == #(0x0000, 0x007F)
/// ```
///
pub fn block_to_range(block_name: String) -> Result(codepoint.Range, Nil) {
  let comparable_property = internal.comparable_property(block_name)
  use pair <- result.try(block_to_range_ffi(comparable_property))
  codepoint.range_from_ints(pair.0, pair.1)
}

@external(javascript, "./unicode/block_map.mjs", "block_to_range")
fn block_to_range_ffi(block_name: String) -> Result(#(Int, Int), Nil)

/// Get the Unicode [`GeneralCategory`](unicode/category.html#GeneralCategory)
/// property of a code point.
///
/// ## Examples
///
/// ```gleam
/// use cp <- result.map(codepoint.from_int(0x0041))
/// assert unicode.category_from_codepoint(cp) == category.LetterUppercase
/// ```
///
pub fn category_from_codepoint(cp: Codepoint) -> GeneralCategory {
  category_from_codepoint_ffi(codepoint.to_int(cp))
}

@external(javascript, "./unicode/category_map.mjs", "codepoint_to_category")
fn category_from_codepoint_ffi(cp: Int) -> GeneralCategory
