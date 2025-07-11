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
