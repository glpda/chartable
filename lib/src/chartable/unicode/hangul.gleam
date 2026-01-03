import chartable
import chartable/unicode/codepoint.{type Codepoint}
import gleam/bool
import gleam/option.{type Option, None, Some}

@internal
pub const syllable_base = 0xAC00

@internal
pub const leading_base = 0x1100

// @internal
// pub const leading_count = 19

@internal
pub const vowel_base = 0x1161

// @internal
// pub const vowel_count = 21

@internal
pub const trailing_base = 0x11A7

@internal
pub const trailing_count = 28

// vowel_count * trailing_count
@internal
pub const syllable_end_count = 588

// leading_count * syllable_end_count
@internal
pub const syllable_count = 11_172

pub type SyllableType {
  /// `"L"` initial consonant conjoining jamo (choseong),
  /// e.g. U+1107 "Hangul Choseong Pieup" ( ᄇ )
  LeadingJamo
  /// `"V"` vowel conjoining jamo (jungseong),
  /// e.g. U+1167 "Hangul Jungseong Yeo" ( ᅧ )
  VowelJamo
  /// `"T"` final consonant conjoining jamo (jongseong),
  /// e.g. U+11AF "Hangul Jongseong Rieul" ( ᆯ )
  TrailingJamo
  /// `"LV"` consonant-vowel precomposed Hangul syllable,
  /// e.g. U+BCBC "Hangul Syllable Byeo" ( 벼 )
  LvSyllable
  /// `"LVT"` consonant-vowel-consonant precomposed Hangul syllable,
  /// e.g. U+BCC4 "Hangul Syllable Byeol" ( 별 )
  LvtSyllable
}

/// Returns the short name `String` of a [`SyllableType`](#SyllableType).
///
/// ## Examples
///
/// ```gleam
/// assert hangul.syllable_type_to_short_name(hangul.LeadingJamo) == "L"
/// ```
///
pub fn syllable_type_to_short_name(syllable_type: SyllableType) -> String {
  case syllable_type {
    LeadingJamo -> "L"
    VowelJamo -> "V"
    TrailingJamo -> "T"
    LvSyllable -> "LV"
    LvtSyllable -> "LVT"
  }
}

/// Returns the long name `String` of a [`SyllableType`](#SyllableType).
///
/// ## Examples
///
/// ```gleam
/// assert hangul.syllable_type_to_long_name(hangul.LeadingJamo) == "Leading_Jamo"
/// ```
///
pub fn syllable_type_to_long_name(syllable_type: SyllableType) -> String {
  case syllable_type {
    LeadingJamo -> "Leading_Jamo"
    VowelJamo -> "Vowel_Jamo"
    TrailingJamo -> "Trailing_Jamo"
    LvSyllable -> "LV_Syllable"
    LvtSyllable -> "LVT_Syllable"
  }
}

/// Converts a name `String` to a [`SyllableType`](#SyllableType) value,
/// syllable type's name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// assert hangul.syllable_type_from_name("Leading Jamo") == Ok(hangul.LeadingJamo)
/// ```
///
pub fn syllable_type_from_name(name: String) -> Result(SyllableType, Nil) {
  case chartable.comparable_property(name) {
    // From short name:
    "l" -> Ok(LeadingJamo)
    "v" -> Ok(VowelJamo)
    "t" -> Ok(TrailingJamo)
    "lv" -> Ok(LvSyllable)
    "lvt" -> Ok(LvtSyllable)
    // From long name:
    "leadingjamo" -> Ok(LeadingJamo)
    "voweljamo" -> Ok(VowelJamo)
    "trailingjamo" -> Ok(TrailingJamo)
    "lvsyllable" -> Ok(LvSyllable)
    "lvtsyllable" -> Ok(LvtSyllable)

    _ -> Error(Nil)
  }
}

/// Get the Hangul "Syllable Type" property of a code point.
///
/// Returns an `Error` if the property is `"Not_Applicable"` (alias `"NA"`).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0x1107)
/// assert hangul.syllable_type_from_codepoint(cp) == Ok(hangul.LeadingJamo)
/// ```
///
pub fn syllable_type_from_codepoint(cp: Codepoint) -> Result(SyllableType, Nil) {
  case codepoint.to_int(cp) {
    // Derived from https://www.unicode.org/Public/UCD/latest/ucd/HangulSyllableType.txt
    cp if 0x1100 <= cp && cp <= 0x115F -> Ok(LeadingJamo)
    cp if 0xA960 <= cp && cp <= 0xA97C -> Ok(LeadingJamo)
    cp if 0x1160 <= cp && cp <= 0x11A7 -> Ok(VowelJamo)
    cp if 0xD7B0 <= cp && cp <= 0xD7C6 -> Ok(VowelJamo)
    cp if 0x11A8 <= cp && cp <= 0x11FF -> Ok(TrailingJamo)
    cp if 0xD7CB <= cp && cp <= 0xD7FB -> Ok(TrailingJamo)
    cp if syllable_base <= cp && cp <= syllable_base + syllable_count -> {
      case { cp - syllable_base } % trailing_count {
        0 -> Ok(LvSyllable)
        _ -> Ok(LvtSyllable)
      }
    }
    _ -> Error(Nil)
  }
}

// Hangul Syllable Decomposition:
// https://www.unicode.org/versions/latest/core-spec/chapter-3/#G56669
@internal
pub fn syllable_full_decomposition(
  cp: Int,
) -> Result(#(Codepoint, Codepoint, Option(Codepoint)), Nil) {
  use <- bool.guard(
    when: cp < syllable_base || syllable_base + syllable_count <= cp,
    return: Error(Nil),
  )
  let syllable_index = cp - syllable_base

  let leading_index = syllable_index / syllable_end_count
  let vowel_index = { syllable_index % syllable_end_count } / trailing_count
  let trailing_index = syllable_index % trailing_count

  let leading_part = codepoint.unsafe(leading_base + leading_index)
  let vowel_part = codepoint.unsafe(vowel_base + vowel_index)
  let trailing_part = case trailing_index {
    0 -> None
    _ -> Some(codepoint.unsafe(trailing_base + trailing_index))
  }
  Ok(#(leading_part, vowel_part, trailing_part))
}
