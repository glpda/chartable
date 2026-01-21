import chartable

/// The "Bidirectional Class" used in the algorithm to present text with altering
/// script direction like a Hebrew quote in an English text.
///
/// See [UAX9-Table4](https://www.unicode.org/reports/tr9/#Bidirectional_Character_Types),
/// and [UAX44-Table13](https://www.unicode.org/reports/tr44/#Bidi_Class_Values).
pub type BidiClass {
  // Strong Types:
  /// `"L"` strong left-to-right characters,
  /// e.g. U+0041 "Latin Capital Letter A" ( A )
  LeftToRight
  /// `"R"` strong right-to-left (non-Arabic) characters,
  /// e.g. U+05D0 "Hebrew Letter Alef" ( א )
  RightToLeft
  /// `"AL"` strong right-to-left (Arabic) characters,
  /// e.g. U+062D "Arabic Letter Hah" ( ح )
  ArabicLetter
  // Weak Types:
  /// `"EN"` ASCII digit or Eastern Arabic-Indic digits,
  /// e.g. U+0032 "Digit Two" ( 2 )
  EuropeanNumber
  /// `"ES"` plus and minus signs,
  /// e.g. U+002B "Plus Sign" ( + )
  EuropeanSeparator
  /// `"ET"` numeric format terminators like currency symbols,
  /// e.g. U+0024 "Dollar Sign" ( $ )
  EuropeanTerminator
  /// `"AN"` Arabic-Indic digits,
  /// e.g. U+0662 "Arabic-Indic Digit Two" ( ٢ )
  ArabicNumber
  /// `"CS"` common separator,
  /// e.g. U+002C "Comma" ( , )
  CommonSeparator
  /// `"NSM"` nonspacing combining marks,
  /// e.g. U+0301 "Combining Acute Accent" ( ◌́ )
  NonspacingMark
  /// `"BN"` most format characters, control codes, or noncharacters,
  /// e.g. U+00AD "Soft Hyphen" (SHY)
  BoundaryNeutral
  // Neutral Types:
  /// `"B"` paragraph separators and newline characters,
  /// e.g. U+000D "Carriage Return" (CR)
  ParagraphSeparator
  /// `"S"` various segment-related control codes
  /// e.g. U+0009 "Character Tabulation" (TAB)
  SegmentSeparator
  /// `"WS"` space characters,
  /// e.g. U+0020 "Space" ( )
  WhiteSpace
  /// `"ON"` most other symbols and punctuation marks,
  /// e.g. U+0021 "Exclamation Mark" ( ! )
  OtherNeutral
  // Explicit Formatting Types:
  /// `"LRE"` only U+202A
  LeftToRightEmbedding
  /// `"LRO"` only U+202D
  LeftToRightOverride
  /// `"RLE"` only U+202B
  RightToLeftEmbedding
  /// `"RLO"` only U+202E
  RightToLeftOverride
  /// `"PDF"` only U+202C
  PopDirectionalFormat
  /// `"LRI"` only U+2066
  LeftToRightIsolate
  /// `"RLI"` only U+2067
  RightToLeftIsolate
  /// `"FSI"` only U+2068
  FirstStrongIsolate
  /// `"PDI"` only U+2069
  PopDirectionalIsolate
}

/// Converts a name `String` to a [`BidiClass`](#BidiClass) value,
/// property's name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// assert bidi.class_from_name("L") == Ok(bidi.LeftToRight)
/// assert bidi.class_from_name("Left to Right") == Ok(bidi.LeftToRight)
/// ```
///
pub fn class_from_name(str: String) -> Result(BidiClass, Nil) {
  case chartable.comparable_property(str) {
    // From short name:
    // - Strong Types:
    "l" -> Ok(LeftToRight)
    "r" -> Ok(RightToLeft)
    "al" -> Ok(ArabicLetter)
    // - Weak Types:
    "en" -> Ok(EuropeanNumber)
    "es" -> Ok(EuropeanSeparator)
    "et" -> Ok(EuropeanTerminator)
    "an" -> Ok(ArabicNumber)
    "cs" -> Ok(CommonSeparator)
    "nsm" -> Ok(NonspacingMark)
    "bn" -> Ok(BoundaryNeutral)
    // - Neutral Types:
    "b" -> Ok(ParagraphSeparator)
    "s" -> Ok(SegmentSeparator)
    "ws" -> Ok(WhiteSpace)
    "on" -> Ok(OtherNeutral)
    // - Explicit Formatting Types:
    "lre" -> Ok(LeftToRightEmbedding)
    "lro" -> Ok(LeftToRightOverride)
    "rle" -> Ok(RightToLeftEmbedding)
    "rlo" -> Ok(RightToLeftOverride)
    "pdf" -> Ok(PopDirectionalFormat)
    "lri" -> Ok(LeftToRightIsolate)
    "rli" -> Ok(RightToLeftIsolate)
    "fsi" -> Ok(FirstStrongIsolate)
    "pdi" -> Ok(PopDirectionalIsolate)
    // From long name:
    // - Strong Types:
    "lefttoright" -> Ok(LeftToRight)
    "righttoleft" -> Ok(RightToLeft)
    "arabicletter" -> Ok(ArabicLetter)
    // - Weak Types:
    "europeannumber" -> Ok(EuropeanNumber)
    "europeanseparator" -> Ok(EuropeanSeparator)
    "europeanterminator" -> Ok(EuropeanTerminator)
    "arabicnumber" -> Ok(ArabicNumber)
    "commonseparator" -> Ok(CommonSeparator)
    "nonspacingmark" -> Ok(NonspacingMark)
    "boundaryneutral" -> Ok(BoundaryNeutral)
    // - Neutral Types:
    "paragraphseparator" -> Ok(ParagraphSeparator)
    "segmentseparator" -> Ok(SegmentSeparator)
    "whitespace" -> Ok(WhiteSpace)
    "otherneutral" -> Ok(OtherNeutral)
    // - Explicit Formatting Types:
    "lefttorightembedding" -> Ok(LeftToRightEmbedding)
    "lefttorightoverride" -> Ok(LeftToRightOverride)
    "righttoleftembedding" -> Ok(RightToLeftEmbedding)
    "righttoleftoverride" -> Ok(RightToLeftOverride)
    "popdirectionalformat" -> Ok(PopDirectionalFormat)
    "lefttorightisolate" -> Ok(LeftToRightIsolate)
    "righttoleftisolate" -> Ok(RightToLeftIsolate)
    "firststrongisolate" -> Ok(FirstStrongIsolate)
    "popdirectionalisolate" -> Ok(PopDirectionalIsolate)

    _ -> Error(Nil)
  }
}

/// Returns the short name `String` of a [`BidiClass`](#BidiClass).
///
/// ## Examples
///
/// ```gleam
/// assert bidi.class_to_short_name(bidi.LeftToRight) == "L"
/// ```
///
pub fn class_to_short_name(class: BidiClass) -> String {
  case class {
    // Strong Types:
    LeftToRight -> "L"
    RightToLeft -> "R"
    ArabicLetter -> "AL"
    // Weak Types:
    EuropeanNumber -> "EN"
    EuropeanSeparator -> "ES"
    EuropeanTerminator -> "ET"
    ArabicNumber -> "AN"
    CommonSeparator -> "CS"
    NonspacingMark -> "NSM"
    BoundaryNeutral -> "BN"
    // Neutral Types:
    ParagraphSeparator -> "B"
    SegmentSeparator -> "S"
    WhiteSpace -> "WS"
    OtherNeutral -> "ON"
    // Explicit Formatting Types:
    LeftToRightEmbedding -> "LRE"
    LeftToRightOverride -> "LRO"
    RightToLeftEmbedding -> "RLE"
    RightToLeftOverride -> "RLO"
    PopDirectionalFormat -> "PDF"
    LeftToRightIsolate -> "LRI"
    RightToLeftIsolate -> "RLI"
    FirstStrongIsolate -> "FSI"
    PopDirectionalIsolate -> "PDI"
  }
}

/// Returns the long name `String` of a [`BidiClass`](#BidiClass).
///
/// ## Examples
///
/// ```gleam
/// assert bidi.class_to_long_name(bidi.LeftToRight) == "Left_To_Right"
/// ```
///
pub fn class_to_long_name(class: BidiClass) -> String {
  case class {
    // Strong Types:
    LeftToRight -> "Left_To_Right"
    RightToLeft -> "Right_To_Left"
    ArabicLetter -> "Arabic_Letter"
    // Weak Types:
    EuropeanNumber -> "European_Number"
    EuropeanSeparator -> "European_Separator"
    EuropeanTerminator -> "European_Terminator"
    ArabicNumber -> "Arabic_Number"
    CommonSeparator -> "Common_Separator"
    NonspacingMark -> "Nonspacing_Mark"
    BoundaryNeutral -> "Boundary_Neutral"
    // Neutral Types:
    ParagraphSeparator -> "Paragraph_Separator"
    SegmentSeparator -> "Segment_Separator"
    WhiteSpace -> "White_Space"
    OtherNeutral -> "Other_Neutral"
    // Explicit Formatting Types:
    LeftToRightEmbedding -> "Left_To_Right_Embedding"
    LeftToRightOverride -> "Left_To_Right_Override"
    RightToLeftEmbedding -> "Right_To_Left_Embedding"
    RightToLeftOverride -> "Right_To_Left_Override"
    PopDirectionalFormat -> "Pop_Directional_Format"
    LeftToRightIsolate -> "Left_To_Right_Isolate"
    RightToLeftIsolate -> "Right_To_Left_Isolate"
    FirstStrongIsolate -> "First_Strong_Isolate"
    PopDirectionalIsolate -> "Pop_Directional_Isolate"
  }
}

pub type Strength {
  Strong
  Weak
  Neutral
  Explicit
}

pub fn strength(class: BidiClass) -> Strength {
  case class {
    LeftToRight | RightToLeft | ArabicLetter -> Strong
    EuropeanNumber
    | EuropeanSeparator
    | EuropeanTerminator
    | ArabicNumber
    | CommonSeparator
    | NonspacingMark
    | BoundaryNeutral -> Weak
    ParagraphSeparator | SegmentSeparator | WhiteSpace | OtherNeutral -> Neutral
    LeftToRightEmbedding
    | LeftToRightOverride
    | RightToLeftEmbedding
    | RightToLeftOverride
    | PopDirectionalFormat
    | LeftToRightIsolate
    | RightToLeftIsolate
    | FirstStrongIsolate
    | PopDirectionalIsolate -> Explicit
  }
}
