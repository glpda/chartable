import chartable
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import gleam/list
import gleam/result

/// The basic types of code points
/// (see [Table 2-3](https://www.unicode.org/versions/latest/core-spec/chapter-2/#G286941))
pub type BasicType {
  /// Visible characters: letters, marks, numbers, punctuations, symbols, and
  /// spaces.
  Graphic
  /// Invisible characters afecting neighboring characters.
  Format
  /// [C0 and C1 control codes](https://www.unicode.org/versions/latest/core-spec/chapter-23/#G20365)
  /// (U+0000..U+001F and U+007F..U+009F)
  Control
  /// [Private-Use Characters](https://www.unicode.org/versions/latest/core-spec/chapter-23/#G19184)
  /// left undefined for third-party non-standard use.
  PrivateUse
  /// [Surrogates](https://www.unicode.org/versions/latest/core-spec/chapter-23/#G24089)
  /// used by UTF-16 encoding to represent supplementary characters.
  Surrogate
  /// [Noncharacters](https://www.unicode.org/versions/latest/core-spec/chapter-23/#G12612)
  /// permanently reserved for internal use (U+FDD0..U+FDEF and any code points
  /// ending in the value FFFE or FFFF, e.g. U+5FFFE).
  NonCharacter
  /// Reserved characters for future assignement.
  Reserved
}

/// Get the basic type of a code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x2B50)
/// assert unicode.basic_type_from_codepoint(cp) == unicode.Graphic
/// ```
///
pub fn basic_type_from_codepoint(cp: Codepoint) -> BasicType {
  case category_from_codepoint(cp) {
    category.Letter(_) -> Graphic
    category.Mark(_) -> Graphic
    category.Number(_) -> Graphic
    category.Punctuation(_) -> Graphic
    category.Symbol(_) -> Graphic
    category.Separator(category.SpaceSeparator) -> Graphic

    category.Other(category.Format) -> Format
    category.Separator(category.LineSeparator) -> Format
    category.Separator(category.ParagraphSeparator) -> Format

    category.Other(category.Control) -> Control
    category.Other(category.PrivateUse) -> PrivateUse
    category.Other(category.Surrogate) -> Surrogate
    _ -> {
      let int = codepoint.to_int(cp)
      case int % 0x10000 {
        0xFFFE | 0xFFFF -> NonCharacter
        _ if 0xFDD0 <= int && int <= 0xFDEF -> NonCharacter
        _ -> Reserved
      }
    }
  }
}

// NOTE: Implementation of the character/codepoint status columns in Table 2-3.
// https://www.unicode.org/versions/latest/core-spec/chapter-2/#G286941
//
// The names of these 2 functions are confusing and they are easy to implement,
// so they are probably not worth poluting the API namespace.
//
// pub fn is_assigned(cp: Codepoint) -> Bool {
//   case category_from_codepoint(cp) {
//     category.Other(category.Surrogate) -> False
//     category.Other(category.Unassigned) -> False
//     _ -> True
//   }
// }
//
// pub fn is_designated(cp: Codepoint) -> Bool {
//   case basic_type_from_codepoint(cp) {
//     Reserved -> False
//     _ -> True
//   }
// }

/// Get the Unicode "Name" property of a code point.
///
/// Returns an empty string if the character does not have a standard name
/// (control or unassigned characters).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x661F)
/// assert unicode.name_from_codepoint(cp) == "CJK UNIFIED IDEOGRAPH-661F"
/// ```
///
pub fn name_from_codepoint(cp: Codepoint) -> String {
  name_from_codepoint_ffi(codepoint.to_int(cp))
}

@external(javascript, "./unicode/name_map.mjs", "get_name")
fn name_from_codepoint_ffi(cp: Int) -> String

/// A contiguous range of code points identified by a name.
///
/// Standard blocks contains a multiple of 16 code points and starts at a
/// location that is a multiple of 16.
pub type Block {
  Block(range: codepoint.Range, name: String, aliases: List(String))
}

/// Get the list of all Unicode blocks.
pub fn blocks() -> List(Block) {
  use #(start, end, name, aliases) <- list.filter_map(blocks_ffi())
  use range <- result.try(codepoint.range_from_ints(start, end))
  Ok(Block(range:, name:, aliases:))
}

@external(javascript, "./unicode/block_map.mjs", "get_list")
fn blocks_ffi() -> List(#(Int, Int, String, List(String)))

/// Get the Unicode block to which a code point belongs.
///
/// Returns an `Error` if the code point is not assigned to any blocks.
/// The default value for the block name of unassigned code points is
/// `"No_Block"` (alias `"NB"`).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x661F)
/// let block_name = case unicode.block_from_codepoint(cp) {
///   Ok(block) -> block.name
///   Error(_) -> "No_Block"
/// }
/// assert block_name == "CJK Unified Ideographs"
/// ```
///
pub fn block_from_codepoint(cp: Codepoint) -> Result(Block, Nil) {
  use #(start, end, name, aliases) <- result.try(
    block_from_codepoint_ffi(codepoint.to_int(cp)),
  )
  use range <- result.try(codepoint.range_from_ints(start, end))
  Ok(Block(range:, name:, aliases:))
}

@external(javascript, "./unicode/block_map.mjs", "codepoint_to_block")
fn block_from_codepoint_ffi(
  cp: Int,
) -> Result(#(Int, Int, String, List(String)), Nil)

// TODO examples
/// Find a Unicode block by its name.
///
/// Name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(ascii) = unicode.block_from_name("Basic Latin")
/// assert codepoint.range_to_ints(ascii.range) == #(0x0000, 0x007F)
/// ```
///
pub fn block_from_name(name: String) -> Result(Block, Nil) {
  use #(start, end, name, aliases) <- result.try(
    block_from_name_ffi(chartable.comparable_property(name)),
  )
  use range <- result.try(codepoint.range_from_ints(start, end))
  Ok(Block(range:, name:, aliases:))
}

@external(javascript, "./unicode/block_map.mjs", "name_to_block")
fn block_from_name_ffi(
  name: String,
) -> Result(#(Int, Int, String, List(String)), Nil)

/// Get the Unicode "General Category" property of a code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x0041)
/// assert unicode.category_from_codepoint(cp) == category.LetterUppercase
/// ```
///
pub fn category_from_codepoint(cp: Codepoint) -> GeneralCategory {
  category_from_codepoint_ffi(codepoint.to_int(cp))
}

@external(javascript, "./unicode/category_map.mjs", "codepoint_to_category")
fn category_from_codepoint_ffi(cp: Int) -> GeneralCategory
