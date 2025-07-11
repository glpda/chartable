//// [General Category Values](https://www.unicode.org/reports/tr44/#General_Category_Values):
//// provides a general classification of every code point,
//// many characters have multiples uses wich are not captured by
//// this simple categories (Latin letters may be used as numerals).

pub type GeneralCategory {
  // Letters:
  /// an uppercase letter
  LetterUppercase
  /// a lowercase letter
  LetterLowercase
  /// a digraph encoded as a single character, with first part uppercase
  LetterTitlecase
  /// a modifier letter
  LetterModifier
  /// other letters, including syllables and ideographs
  LetterOther

  // Marks:
  /// a nonspacing combining mark (zero advance width)
  MarkNonspacing
  /// a spacing combining mark (positive advance width)
  MarkSpacing
  /// an enclosing combining mark
  MarkEnclosing

  // Numbers:
  /// a decimal digit
  NumberDecimal
  /// a letterlike numeric character
  NumberLetter
  /// a numeric character of other type
  NumberOther

  // Punctuations:
  /// a connecting punctuation mark, like a tie
  PunctuationConnector
  /// a dash or hyphen punctuation mark
  PunctuationDash
  /// an opening punctuation mark (of a pair)
  PunctuationOpen
  /// a closing punctuation mark (of a pair)
  PunctuationClose
  /// an initial quotation mark
  PunctuationIntial
  /// a final quotation mark
  PunctuationFinal
  /// a punctuation mark of other type
  PunctuationOther

  // Symbols:
  /// a symbol of mathematical use
  SymbolMath
  /// a currency sign
  SymbolCurrency
  /// a non-letterlike modifier symbol
  SymbolModifier
  /// a symbol of other type
  SymbolOther

  // Separators:
  /// a space character (of various non-zero widths)
  SeparatorSpace
  /// U+2028 LINE SEPARATOR only
  SeparatorLine
  /// U+2029 PARAGRAPH SEPARATOR only
  SeparatorParagraph

  // Others:
  /// a C0 or C1 control code
  Control
  /// a format control character
  Format
  /// a surrogate code point
  Surrogate
  /// a private-use character
  PrivateUse
  /// a reserved unassigned code point or a noncharacter
  Unassigned
}

/// Converts an abbreviation `String` to a [`GeneralCategory`](#GeneralCategory).
///
/// ## Examples
///
/// ```gleam
/// assert Ok(category.LetterUppercase) == category.from_abbreviation("Lu")
/// assert Ok(category.Unassigned) == category.from_abbreviation("Cn")
/// assert Ok(category.SymbolMath) == category.from_abbreviation("Sm")
/// assert Error(Nil) == category.from_abbreviation("Xyz")
/// ```
///
pub fn from_abbreviation(abbr: String) -> Result(GeneralCategory, Nil) {
  case abbr {
    // Letters
    "Lu" -> Ok(LetterUppercase)
    "Ll" -> Ok(LetterLowercase)
    "Lt" -> Ok(LetterTitlecase)
    "Lm" -> Ok(LetterModifier)
    "Lo" -> Ok(LetterOther)
    // Marks:
    "Mn" -> Ok(MarkNonspacing)
    "Mc" -> Ok(MarkSpacing)
    "Me" -> Ok(MarkEnclosing)
    // Numbers:
    "Nd" -> Ok(NumberDecimal)
    "Nl" -> Ok(NumberLetter)
    "No" -> Ok(NumberOther)
    // Punctuations:
    "Pc" -> Ok(PunctuationConnector)
    "Pd" -> Ok(PunctuationDash)
    "Ps" -> Ok(PunctuationOpen)
    "Pe" -> Ok(PunctuationClose)
    "Pi" -> Ok(PunctuationIntial)
    "Pf" -> Ok(PunctuationFinal)
    "Po" -> Ok(PunctuationOther)
    // Symbols:
    "Sm" -> Ok(SymbolMath)
    "Sc" -> Ok(SymbolCurrency)
    "Sk" -> Ok(SymbolModifier)
    "So" -> Ok(SymbolOther)
    // Separators:
    "Zs" -> Ok(SeparatorSpace)
    "Zl" -> Ok(SeparatorLine)
    "Zp" -> Ok(SeparatorParagraph)
    // Others:
    "Cc" -> Ok(Control)
    "Cf" -> Ok(Format)
    "Cs" -> Ok(Surrogate)
    "Co" -> Ok(PrivateUse)
    "Cn" -> Ok(Unassigned)

    _ -> Error(Nil)
  }
}

/// Converts a [`GeneralCategory`](#GeneralCategory) to an abbreviation `String`.
///
/// ## Examples
///
/// ```gleam
/// assert "Lu" == category.to_abbreviation(category.LetterUppercase)
/// assert "Cn" == category.to_abbreviation(category.Unassigned)
/// assert "Sm" == category.to_abbreviation(category.SymbolMath)
/// ```
///
pub fn to_abbreviation(category: GeneralCategory) -> String {
  case category {
    // Letters:
    LetterUppercase -> "Lu"
    LetterLowercase -> "Ll"
    LetterTitlecase -> "Lt"
    LetterModifier -> "Lm"
    LetterOther -> "Lo"
    // Marks:
    MarkNonspacing -> "Mn"
    MarkSpacing -> "Mc"
    MarkEnclosing -> "Me"
    // Numbers:
    NumberDecimal -> "Nd"
    NumberLetter -> "Nl"
    NumberOther -> "No"
    // Punctuations:
    PunctuationConnector -> "Pc"
    PunctuationDash -> "Pd"
    PunctuationOpen -> "Ps"
    PunctuationClose -> "Pe"
    PunctuationIntial -> "Pi"
    PunctuationFinal -> "Pf"
    PunctuationOther -> "Po"
    // Symbols:
    SymbolMath -> "Sm"
    SymbolCurrency -> "Sc"
    SymbolModifier -> "Sk"
    SymbolOther -> "So"
    // Separators:
    SeparatorSpace -> "Zs"
    SeparatorLine -> "Zl"
    SeparatorParagraph -> "Zp"
    // Others:
    Control -> "Cc"
    Format -> "Cf"
    Surrogate -> "Cs"
    PrivateUse -> "Co"
    Unassigned -> "Cn"
  }
}

/// Converts a long name `String` to a [`GeneralCategory`](#GeneralCategory).
///
/// ## Examples
///
/// ```gleam
/// assert Ok(category.LetterUppercase)
///   == category.from_long_name("Uppercase_Letter")
/// assert Ok(category.Unassigned) == category.from_long_name("Unassigned")
/// assert Ok(category.SymbolMath) == category.from_long_name("Math_Symbol")
/// assert Error(Nil) == category.from_abbreviation("Xyz")
/// ```
///
pub fn from_long_name(name: String) -> Result(GeneralCategory, Nil) {
  case name {
    // Letters
    "Uppercase_Letter" -> Ok(LetterUppercase)
    "Lowercase_Letter" -> Ok(LetterLowercase)
    "Titlecase_Letter" -> Ok(LetterTitlecase)
    "Modifier_Letter" -> Ok(LetterModifier)
    "Other_Letter" -> Ok(LetterOther)
    // Marks:
    "Nonspacing_Mark" -> Ok(MarkNonspacing)
    "Spacing_Mark" -> Ok(MarkSpacing)
    "Enclosing_Mark" -> Ok(MarkEnclosing)
    // Numbers:
    "Decimal_Number" -> Ok(NumberDecimal)
    "Letter_Number" -> Ok(NumberLetter)
    "Other_Number" -> Ok(NumberOther)
    // Punctuations:
    "Connector_Punctuation" -> Ok(PunctuationConnector)
    "Dash_Punctuation" -> Ok(PunctuationDash)
    "Open_Punctuation" -> Ok(PunctuationOpen)
    "Close_Punctuation" -> Ok(PunctuationClose)
    "Initial_Punctuation" -> Ok(PunctuationIntial)
    "Final_Punctuation" -> Ok(PunctuationFinal)
    "Other_Punctuation" -> Ok(PunctuationOther)
    // Symbols:
    "Math_Symbol" -> Ok(SymbolMath)
    "Currency_Symbol" -> Ok(SymbolCurrency)
    "Modifier_Symbol" -> Ok(SymbolModifier)
    "Other_Symbol" -> Ok(SymbolOther)
    // Separators:
    "Space_Separator" -> Ok(SeparatorSpace)
    "Line_Separator" -> Ok(SeparatorLine)
    "Paragraph_Separator" -> Ok(SeparatorParagraph)
    // Others:
    "Control" -> Ok(Control)
    "Format" -> Ok(Format)
    "Surrogate" -> Ok(Surrogate)
    "Private_Use" -> Ok(PrivateUse)
    "Unassigned" -> Ok(Unassigned)

    _ -> Error(Nil)
  }
}

/// Converts a [`GeneralCategory`](#GeneralCategory) to a long name `String`.
///
/// ## Examples
///
/// ```gleam
/// assert "Uppercase_Letter" == category.to_long_name(category.LetterUppercase)
/// assert "Unassigned" == category.to_long_name(category.Unassigned)
/// assert "Math_Symbol" == category.to_long_name(category.SymbolMath)
/// ```
///
pub fn to_long_name(category: GeneralCategory) -> String {
  case category {
    // Letters:
    LetterUppercase -> "Uppercase_Letter"
    LetterLowercase -> "Lowercase_Letter"
    LetterTitlecase -> "Titlecase_Letter"
    LetterModifier -> "Modifier_Letter"
    LetterOther -> "Other_Letter"
    // Marks:
    MarkNonspacing -> "Nonspacing_Mark"
    MarkSpacing -> "Spacing_Mark"
    MarkEnclosing -> "Enclosing_Mark"
    // Numbers:
    NumberDecimal -> "Decimal_Number"
    NumberLetter -> "Letter_Number"
    NumberOther -> "Other_Number"
    // Punctuations:
    PunctuationConnector -> "Connector_Punctuation"
    PunctuationDash -> "Dash_Punctuation"
    PunctuationOpen -> "Open_Punctuation"
    PunctuationClose -> "Close_Punctuation"
    PunctuationIntial -> "Initial_Punctuation"
    PunctuationFinal -> "Final_Punctuation"
    PunctuationOther -> "Other_Punctuation"
    // Symbols:
    SymbolMath -> "Math_Symbol"
    SymbolCurrency -> "Currency_Symbol"
    SymbolModifier -> "Modifier_Symbol"
    SymbolOther -> "Other_Symbol"
    // Separators:
    SeparatorSpace -> "Space_Separator"
    SeparatorLine -> "Line_Separator"
    SeparatorParagraph -> "Paragraph_Separator"
    // Others:
    Control -> "Control"
    Format -> "Format"
    Surrogate -> "Surrogate"
    PrivateUse -> "Private_Use"
    Unassigned -> "Unassigned"
  }
}
