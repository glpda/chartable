import chartable
import chartable/unicode/bidi.{type BidiClass}
import chartable/unicode/category.{type GeneralCategory}
import chartable/unicode/codepoint.{type Codepoint}
import chartable/unicode/combining_class.{type CombiningClass}
import chartable/unicode/hangul
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

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
    _ ->
      case is_noncharacter(cp) {
        True -> NonCharacter
        False -> Reserved
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

    "" if { 0x18800 <= cp && cp <= 0x18AFF } ->
      "TANGUT COMPONENT-"
      <> int.to_string(cp - 0x18800 + 1) |> string.pad_start(to: 3, with: "0")
    "" if { 0x18D80 <= cp && cp <= 0x18DF2 } ->
      "TANGUT COMPONENT-"
      <> int.to_string(cp - 0x18D80 + 769) |> string.pad_start(to: 3, with: "0")

    "" if { 0x18B00 <= cp && cp <= 0x18CD5 } || cp == 0x18CFF ->
      "KHITAN SMALL SCRIPT CHARACTER-" <> codepoint.int_to_hex(cp)

    "" if 0x1B170 <= cp && cp <= 0x1B2FB ->
      "NUSHU CHARACTER-" <> codepoint.int_to_hex(cp)

    "" if { 0xFE00 <= cp && cp <= 0xFE0F } ->
      "VARIATION SELECTOR-" <> int.to_string(cp - 0xFE00 + 1)
    "" if { 0xE0100 <= cp && cp <= 0xE01EF } ->
      "VARIATION SELECTOR-" <> int.to_string(cp - 0xE0100 + 17)

    "" ->
      case hangul.syllable_full_decomposition(codepoint) {
        Ok(#(leading, vowel, None)) ->
          "HANGUL SYLLABLE "
          <> hangul.jamo_short_name(leading)
          <> hangul.jamo_short_name(vowel)
        Ok(#(leading, vowel, Some(trailing))) ->
          "HANGUL SYLLABLE "
          <> hangul.jamo_short_name(leading)
          <> hangul.jamo_short_name(vowel)
          <> hangul.jamo_short_name(trailing)
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

/// Get the Unicode "Combining Class" property of a code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x0301)
/// let above = unicode.combining_class_from_codepoint(cp)
/// assert combining_class.to_int(above) == 230
/// ```
///
pub fn combining_class_from_codepoint(cp: Codepoint) -> CombiningClass {
  codepoint.to_int(cp)
  |> combining_class_from_codepoint_ffi
  |> combining_class.unsafe
}

@external(javascript, "./unicode/combining_class_map.mjs", "codepoint_to_combining_class")
fn combining_class_from_codepoint_ffi(cp: Int) -> Int

/// Get the Unicode "Bidi Class" property of a code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x05D0)
/// let rtl = unicode.bidi_class_from_codepoint(cp)
/// assert bidi.class_to_long_name(rtl) == "Right_To_Left"
/// ```
///
pub fn bidi_class_from_codepoint(codepoint: Codepoint) -> BidiClass {
  let cp = codepoint.to_int(codepoint)
  use <- result.lazy_unwrap(bidi_class_from_codepoint_ffi(cp))
  case basic_type_from_codepoint(codepoint) {
    NonCharacter -> bidi.BoundaryNeutral
    Reserved ->
      case is_default_ignorable(codepoint) {
        True -> bidi.BoundaryNeutral
        False -> bidi.LeftToRight
      }
    _ -> bidi.LeftToRight
  }
}

@external(javascript, "./unicode/bidi_class_map.mjs", "codepoint_to_bidi_class")
fn bidi_class_from_codepoint_ffi(cp: Int) -> Result(BidiClass, Nil)

pub fn full_decomposition(codepoint: Codepoint) -> List(Codepoint) {
  // TODO add all full decompositions
  case hangul.syllable_full_decomposition(codepoint) {
    Ok(#(leading, vowel, None)) -> [leading, vowel]
    Ok(#(leading, vowel, Some(trailing))) -> [leading, vowel, trailing]
    Error(Nil) -> [codepoint]
  }
}

pub fn is_default_ignorable(codepoint: Codepoint) -> Bool {
  case codepoint.to_int(codepoint) {
    0x00AD -> True
    0x034F -> True
    0x061C -> True
    cp if 0x115F <= cp && cp <= 0x1160 -> True
    cp if 0x17B4 <= cp && cp <= 0x17B5 -> True
    cp if 0x180B <= cp && cp <= 0x180D -> True
    0x180E -> True
    0x180F -> True
    cp if 0x200B <= cp && cp <= 0x200F -> True
    cp if 0x202A <= cp && cp <= 0x202E -> True
    cp if 0x2060 <= cp && cp <= 0x2064 -> True
    0x2065 -> True
    cp if 0x2066 <= cp && cp <= 0x206F -> True
    0x3164 -> True
    cp if 0xFE00 <= cp && cp <= 0xFE0F -> True
    0xFEFF -> True
    0xFFA0 -> True
    cp if 0xFFF0 <= cp && cp <= 0xFFF8 -> True
    cp if 0x1BCA0 <= cp && cp <= 0x1BCA3 -> True
    cp if 0x1D173 <= cp && cp <= 0x1D17A -> True
    0xE0000 -> True
    0xE0001 -> True
    cp if 0xE0002 <= cp && cp <= 0xE001F -> True
    cp if 0xE0020 <= cp && cp <= 0xE007F -> True
    cp if 0xE0080 <= cp && cp <= 0xE00FF -> True
    cp if 0xE0100 <= cp && cp <= 0xE01EF -> True
    cp if 0xE01F0 <= cp && cp <= 0xE0FFF -> True
    _ -> False
  }
}

@internal
pub fn is_default_ignorable_derived(codepoint: Codepoint) -> Bool {
  // Set Additions/Substractions:
  // Other_Default_Ignorable_Code_Point
  // + Cf (Format characters)
  // + Variation_Selector
  // - White_Space
  // - FFF9..FFFB (Interlinear annotation format characters)
  // - 13430..13440 (Egyptian hieroglyph format characters)
  // - Prepended_Concatenation_Mark (Exceptional format characters that should be visible)
  let cp = codepoint.to_int(codepoint)
  case cp {
    0x034F -> True
    cp if 0x115F <= cp && cp <= 0x1160 -> True
    cp if 0x17B4 <= cp && cp <= 0x17B5 -> True
    0x2065 -> True
    0x3164 -> True
    0xFFA0 -> True
    cp if 0xFFF0 <= cp && cp <= 0xFFF8 -> True
    0xE0000 -> True
    cp if 0xE0002 <= cp && cp <= 0xE001F -> True
    cp if 0xE0080 <= cp && cp <= 0xE00FF -> True
    cp if 0xE01F0 <= cp && cp <= 0xE0FFF -> True
    _ ->
      case category_from_codepoint(codepoint) {
        category.Other(category.Format) -> True
        _ -> is_variation_selector(codepoint)
      }
  }
  && case cp {
    cp if 0xFFF9 <= cp && cp <= 0xFFFB -> False
    cp if 0x13430 <= cp && cp <= 0x13440 -> False
    _ ->
      !is_white_space(codepoint) && !is_prepended_concatenation_mark(codepoint)
  }
}

@internal
pub fn is_noncharacter(codepoint: Codepoint) -> Bool {
  let cp = codepoint.to_int(codepoint)
  case cp % 0x10000 {
    0xFFFE | 0xFFFF -> True
    _ if 0xFDD0 <= cp && cp <= 0xFDEF -> True
    _ -> False
  }
}

pub fn is_prepended_concatenation_mark(codepoint: Codepoint) -> Bool {
  case codepoint.to_int(codepoint) {
    cp if 0x0600 <= cp && cp <= 0x0605 -> True
    0x06DD -> True
    0x070F -> True
    cp if 0x0890 <= cp && cp <= 0x0891 -> True
    0x08E2 -> True
    0x110BD -> True
    0x110CD -> True
    _ -> False
  }
}

pub fn is_variation_selector(codepoint: Codepoint) -> Bool {
  case codepoint.to_int(codepoint) {
    cp if 0x180B <= cp && cp <= 0x180D -> True
    0x180F -> True
    cp if 0xFE00 <= cp && cp <= 0xFE0F -> True
    cp if 0xE0100 <= cp && cp <= 0xE01EF -> True
    _ -> False
  }
}

pub fn is_white_space(codepoint: Codepoint) -> Bool {
  case codepoint.to_int(codepoint) {
    cp if 0x0009 <= cp && cp <= 0x000D -> True
    0x0020 -> True
    0x0085 -> True
    0x00A0 -> True
    0x1680 -> True
    cp if 0x2000 <= cp && cp <= 0x200A -> True
    0x2028 -> True
    0x2029 -> True
    0x202F -> True
    0x205F -> True
    0x3000 -> True
    _ -> False
  }
}
