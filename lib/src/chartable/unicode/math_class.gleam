import chartable/internal

/// Unicode Mathematical Classification
///
/// See [UTR25](https://www.unicode.org/reports/tr25/).
///
/// Characters wich are not classified would most likely fall into class N or A.
pub type MathClass {
  /// `"N"` all digits and symbols requiring only one form,
  /// e.g. U+0024 "Dollar Sign" ( $ )
  Normal
  /// `"A"` alphabetic charactersm,
  /// e.g. U+0393 "Greek Capital Letter Gamma" ( Γ )
  Alphabetic
  /// `"D"` diacritics & accents,
  /// e.g. U+0302 "Combining Circumflex Accent" ( ◌̂ )
  Diacritic
  /// `"U"` unary operators,
  /// e.g. U+00AC "Not Sign" ( ¬◌ )
  Unary
  /// `"B"` binary operators,
  /// e.g. U+00D7 "Multiplication Sign" ( ◌×◌ )
  Binary
  /// `"V"` operators that can be unary or binary depending on context,
  /// e.g. U+2212 "Minus Sign" ( −◌ | ◌−◌ )
  Vary
  /// `"L"` N-ary or Large operators,
  /// e.g. U+2211 "N-ary Summation" ( ∑… )
  Large
  /// `"R"` relations,
  /// e.g. U+003D "Equals Sign" ( ◌=◌ )
  Relation
  /// `"G"` pieces of large operator,
  /// e.g. U+23B2 "Summation Top" ( ⎲ )
  GlyphPart
  /// `"O"` opening delimiter (usually paired with closing delimiter),
  /// e.g. U+007B "Left Curly Bracket" ( {… )
  Opening
  /// `"C"` closing delimiter (usually paired with opening delimiter),
  /// e.g. U+007D "Right Curly Bracket" ( …} )
  Closing
  /// `"F"` unpaired delimiter (often used as opening or closing),
  /// e.g. U+007C "Vertical Line" ( …|… )
  Fence
  /// `"S"` white spaces,
  /// e.g. U+00A0 "No-Break Space" (NBSP)
  Space
  /// `"P"` punctuations,
  /// e.g. U+003A "Colon" ( : )
  Punctuation
  /// `"X"` characters not covered by other classes,
  /// e.g. U+3008 "Left Angle Bracket" ( 〈… deprecated for math use)
  Special
}

pub fn from_name(str: String) {
  case internal.comparable_property(str) {
    // From short name:
    "n" -> Ok(Normal)
    "a" -> Ok(Alphabetic)
    "d" -> Ok(Diacritic)
    "u" -> Ok(Unary)
    "b" -> Ok(Binary)
    "v" -> Ok(Vary)
    "l" -> Ok(Large)
    "r" -> Ok(Relation)
    "g" -> Ok(GlyphPart)
    "o" -> Ok(Opening)
    "c" -> Ok(Closing)
    "f" -> Ok(Fence)
    "s" -> Ok(Space)
    "p" -> Ok(Punctuation)
    "x" -> Ok(Special)
    // From long name:
    "normal" -> Ok(Normal)
    "alphabetic" -> Ok(Alphabetic)
    "diacritic" -> Ok(Diacritic)
    "unary" -> Ok(Unary)
    "binary" -> Ok(Binary)
    "vary" -> Ok(Vary)
    "large" -> Ok(Large)
    "relation" -> Ok(Relation)
    "glyphpart" -> Ok(GlyphPart)
    "opening" -> Ok(Opening)
    "closing" -> Ok(Closing)
    "fence" -> Ok(Fence)
    "space" -> Ok(Space)
    "punctuation" -> Ok(Punctuation)
    "special" -> Ok(Special)

    _ -> Error(Nil)
  }
}

pub fn to_short_name(math_class: MathClass) {
  case math_class {
    Normal -> "N"
    Alphabetic -> "A"
    Diacritic -> "D"
    Unary -> "U"
    Binary -> "B"
    Vary -> "V"
    Large -> "L"
    Relation -> "R"
    GlyphPart -> "G"
    Opening -> "O"
    Closing -> "C"
    Fence -> "F"
    Space -> "S"
    Punctuation -> "P"
    Special -> "X"
  }
}

pub fn to_long_name(math_class: MathClass) {
  case math_class {
    Normal -> "Normal"
    Alphabetic -> "Alphabetic"
    Diacritic -> "Diacritic"
    Unary -> "Unary"
    Binary -> "Binary"
    Vary -> "Vary"
    Large -> "Large"
    Relation -> "Relation"
    GlyphPart -> "Glyph_Part"
    Opening -> "Opening"
    Closing -> "Closing"
    Fence -> "Fence"
    Space -> "Space"
    Punctuation -> "Punctuation"
    Special -> "Special"
  }
}
