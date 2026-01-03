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
pub fn syllable_canonical_decomposition(
  codepoint: Codepoint,
) -> Result(#(Codepoint, Codepoint), Nil) {
  let cp = codepoint.to_int(codepoint)
  use <- bool.guard(
    when: cp < syllable_base || syllable_base + syllable_count <= cp,
    return: Error(Nil),
  )
  let syllable_index = cp - syllable_base
  case syllable_index % trailing_count {
    0 -> {
      let leading_index = syllable_index / syllable_end_count
      let vowel_index = { syllable_index % syllable_end_count } / trailing_count
      let leading_part = codepoint.unsafe(leading_base + leading_index)
      let vowel_part = codepoint.unsafe(vowel_base + vowel_index)
      Ok(#(leading_part, vowel_part))
    }
    _ -> {
      let lv_index = { syllable_index / trailing_count } * trailing_count
      let trailing_index = syllable_index % trailing_count
      let lv_part = codepoint.unsafe(syllable_base + lv_index)
      let trailing_part = codepoint.unsafe(trailing_base + trailing_index)
      Ok(#(lv_part, trailing_part))
    }
  }
}

@internal
pub fn syllable_full_decomposition(
  codepoint: Codepoint,
) -> Result(#(Codepoint, Codepoint, Option(Codepoint)), Nil) {
  let cp = codepoint.to_int(codepoint)
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

/// Returns the `Jamo_Short_Name` string of a code point.
///
/// This is a contributory property used to build the names of Hangul syllables.
@internal
pub fn jamo_short_name(codepoint: Codepoint) -> String {
  case codepoint.to_int(codepoint) {
    // Derived from https://www.unicode.org/Public/UCD/latest/ucd/Jamo.txt
    0x1100 -> "G"
    0x1101 -> "GG"
    0x1102 -> "N"
    0x1103 -> "D"
    0x1104 -> "DD"
    0x1105 -> "R"
    0x1106 -> "M"
    0x1107 -> "B"
    0x1108 -> "BB"
    0x1109 -> "S"
    0x110A -> "SS"
    0x110B -> ""
    0x110C -> "J"
    0x110D -> "JJ"
    0x110E -> "C"
    0x110F -> "K"
    0x1110 -> "T"
    0x1111 -> "P"
    0x1112 -> "H"
    0x1161 -> "A"
    0x1162 -> "AE"
    0x1163 -> "YA"
    0x1164 -> "YAE"
    0x1165 -> "EO"
    0x1166 -> "E"
    0x1167 -> "YEO"
    0x1168 -> "YE"
    0x1169 -> "O"
    0x116A -> "WA"
    0x116B -> "WAE"
    0x116C -> "OE"
    0x116D -> "YO"
    0x116E -> "U"
    0x116F -> "WEO"
    0x1170 -> "WE"
    0x1171 -> "WI"
    0x1172 -> "YU"
    0x1173 -> "EU"
    0x1174 -> "YI"
    0x1175 -> "I"
    0x11A8 -> "G"
    0x11A9 -> "GG"
    0x11AA -> "GS"
    0x11AB -> "N"
    0x11AC -> "NJ"
    0x11AD -> "NH"
    0x11AE -> "D"
    0x11AF -> "L"
    0x11B0 -> "LG"
    0x11B1 -> "LM"
    0x11B2 -> "LB"
    0x11B3 -> "LS"
    0x11B4 -> "LT"
    0x11B5 -> "LP"
    0x11B6 -> "LH"
    0x11B7 -> "M"
    0x11B8 -> "B"
    0x11B9 -> "BS"
    0x11BA -> "S"
    0x11BB -> "SS"
    0x11BC -> "NG"
    0x11BD -> "J"
    0x11BE -> "C"
    0x11BF -> "K"
    0x11C0 -> "T"
    0x11C1 -> "P"
    0x11C2 -> "H"
    _ -> ""
  }
}
