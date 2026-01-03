import chartable
import chartable/internal/jamo
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import chartable/unicode/hangul
import gleam/bool
import gleam/list
import gleam/option.{None, Some}
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
pub fn name_from_codepoint(codepoint: Codepoint) -> String {
  let cp = codepoint.to_int(codepoint)
  case name_from_codepoint_ffi(cp) {
    ""
      if { 0x3400 <= cp && cp <= 0x4DBF }
      || { 0x4E00 <= cp && cp <= 0x9FFF }
      || { 0x20000 <= cp && cp <= 0x2A6DF }
      || { 0x2A700 <= cp && cp <= 0x2B81D }
      || { 0x2B820 <= cp && cp <= 0x2CEAD }
      || { 0x2CEB0 <= cp && cp <= 0x2EBE0 }
      || { 0x2EBF0 <= cp && cp <= 0x2EE5D }
      || { 0x30000 <= cp && cp <= 0x3134A }
      || { 0x31350 <= cp && cp <= 0x33479 }
    -> "CJK UNIFIED IDEOGRAPH-" <> codepoint.int_to_hex(cp)

    ""
      if { 0xF900 <= cp && cp <= 0xFA6D }
      || { 0xFA70 <= cp && cp <= 0xFAD9 }
      || { 0x2F800 <= cp && cp <= 0x2FA1D }
    -> "CJK COMPATIBILITY IDEOGRAPH-" <> codepoint.int_to_hex(cp)

    "" if 0x13460 <= cp && cp <= 0x143FA ->
      "EGYPTIAN HIEROGLYPH-" <> codepoint.int_to_hex(cp)

    ""
      if { 0x17000 <= cp && cp <= 0x187FF }
      || { 0x18D00 <= cp && cp <= 0x18D1E }
    -> "TANGUT IDEOGRAPH-" <> codepoint.int_to_hex(cp)

    "" if { 0x18B00 <= cp && cp <= 0x18CD5 } || cp == 0x18CFF ->
      "KHITAN SMALL SCRIPT CHARACTER-" <> codepoint.int_to_hex(cp)

    "" if 0x1B170 <= cp && cp <= 0x1B2FB ->
      "NUSHU CHARACTER-" <> codepoint.int_to_hex(cp)

    "" ->
      case hangul.syllable_full_decomposition(cp) {
        Ok(#(leading, vowel, None)) ->
          "HANGUL SYLLABLE "
          <> jamo.short_name(leading)
          <> jamo.short_name(vowel)
        Ok(#(leading, vowel, Some(trailing))) ->
          "HANGUL SYLLABLE "
          <> jamo.short_name(leading)
          <> jamo.short_name(vowel)
          <> jamo.short_name(trailing)
        Error(Nil) -> ""
      }

    name -> name
  }
}

@external(javascript, "./unicode/name_map.mjs", "get_name")
fn name_from_codepoint_ffi(cp: Int) -> String

/// [Character Name Aliases](https://www.unicode.org/versions/latest/core-spec/chapter-4/#G141423):
/// additional names for code points.
pub type NameAliases {
  NameAliases(
    /// Corrections for serious problems in the character names.
    corrections: List(String),
    /// SO 6429 names for C0 and C1 control functions, and other commonly
    /// occurring names for control codes.
    controls: List(String),
    /// A few widely used alternate names for format characters.
    alternates: List(String),
    /// Several documented labels for C1 control code points which were never
    /// actually approved in any standard.
    figments: List(String),
    /// Commonly occurring abbreviations (or acronyms) for control codes, format
    /// characters, spaces, and variation selectors.
    abbreviations: List(String),
  )
}

/// Get the "Name Aliases" of a code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x000A)
/// assert unicode.aliases_from_codepoint(cp).controls
///   == ["LINE FEED", "NEW LINE", "END OF LINE"]
/// ```
///
pub fn aliases_from_codepoint(cp: Codepoint) -> NameAliases {
  let #(corrections, controls, alternates, figments, abbreviations) =
    aliases_from_codepoint_ffi(codepoint.to_int(cp))
  NameAliases(corrections:, controls:, alternates:, figments:, abbreviations:)
}

@external(javascript, "./unicode/name_alias_map.mjs", "get_aliases")
fn aliases_from_codepoint_ffi(
  int: Int,
) -> #(List(String), List(String), List(String), List(String), List(String))

/// Get the Name label of a code point.
/// Prefer this to `name_from_codepoint` for display and user interfaces
/// (never returns an empty string).
///
/// Returns the first correction alias if the code point has one,
/// otherwise returns the standard name unless the code point is unnamed
/// (control or unassigned characters),
/// in such case returns a fallback label.
///
/// See [Unicode Core Specification 4.8.2](https://www.unicode.org/versions/latest/core-spec/chapter-4/#G135248)
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x000A)
/// assert label_from_codepoint(cp) == "<control-000A>"
/// ```
///
pub fn label_from_codepoint(cp: Codepoint) -> String {
  let aliases = aliases_from_codepoint(cp)
  use <- result.lazy_unwrap(list.first(aliases.corrections))
  let name = name_from_codepoint(cp)
  use <- bool.guard(when: name != "", return: name)
  let hex = codepoint.to_hex(cp)
  let label = case basic_type_from_codepoint(cp) {
    Control -> "control-"
    Reserved -> "reserved-"
    NonCharacter -> "noncharacter-"
    PrivateUse -> "private-use-"
    Surrogate -> "surrogate-"
    // should not be reachable as all graphic and format codepoints are named:
    Format -> "format-"
    Graphic -> "graphic-"
  }
  "<" <> label <> hex <> ">"
}

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

pub fn full_decomposition(codepoint: Codepoint) -> List(Codepoint) {
  let cp = codepoint.to_int(codepoint)
  // TODO add all full decompositions
  case hangul.syllable_full_decomposition(cp) {
    Ok(#(leading, vowel, None)) -> [leading, vowel]
    Ok(#(leading, vowel, Some(trailing))) -> [leading, vowel, trailing]
    Error(Nil) -> [codepoint]
  }
}
