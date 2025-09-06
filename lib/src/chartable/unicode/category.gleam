//// [General Category Values](https://www.unicode.org/reports/tr44/#General_Category_Values):
//// provides a general classification of every code point,
//// many characters have multiples uses wich are not captured by
//// this simple categories (Latin letters may be used as numerals).

import chartable/internal

pub type GeneralCategory {
  // Letters:
  /// `"Lu"` uppercase letters,
  /// e.g. U+0041 "Latin Capital Letter A" ( A )
  LetterUppercase
  /// `"Ll"` lowercase letters,
  /// e.g. U+0061 "Latin Small Letter A" ( a )
  LetterLowercase
  /// `"Lt"`  digraphs encoded as a single character, with first part uppercase,
  /// e.g. U+01F2 "Latin Capital Letter D with Small Letter Z" ( ǲ )
  LetterTitlecase
  /// `"Lm"` modifier letters,
  /// e.g. U+02B0 "Modifier Letter Small H" ( ʰ )
  LetterModifier
  /// `"Lo"` other letters, including syllables and ideographs,
  /// e.g. U+661F "CJK Ideograph for Star" ( 星 )
  LetterOther

  // Marks:
  /// `"Mn"` nonspacing combining marks (zero advance width),
  /// e.g. U+0301 "Combining Acute Accent" ( ◌́ )
  MarkNonspacing
  /// `"Mc"` spacing combining marks (positive advance width),
  /// e.g. U+0903 "Devanagari Sign Visarga" ( ◌ः )
  MarkSpacing
  /// `"Me"` enclosing combining marks,
  /// e.g. U+20E0 "Combining Enclosing Circle Backslash" ( ◌⃠ )
  MarkEnclosing

  // Numbers:
  /// `"Nd"` decimal digits,
  /// e.g. U+0032 "Digit Two" ( 2 )
  NumberDecimal
  /// `"Nl"` letterlike numeric characters,
  /// e.g. U+2162 "Roman Numeral Three" ( Ⅲ )
  NumberLetter
  /// `"No"` numeric character of other type,
  /// e.g. U+00BD "Vulgar Fraction One Half" ( ½ )
  NumberOther

  // Punctuations:
  /// `"Pc"`, connecting punctuation marks,
  /// e.g. U+2040 "Character Tie" (◌⁀◌)
  PunctuationConnector
  /// `"Pd"` dash or hyphen punctuation marks,
  /// e.g. U+2013 "En Dash" ( – )
  PunctuationDash
  /// `"Ps"` opening/starting punctuation marks (of a pair),
  /// e.g. U+007B "Left Curly Bracket" ( { )
  PunctuationOpen
  /// `"Pe"` closing/ending punctuation marks (of a pair),
  /// e.g. U+007D "Right Curly Bracket" ( } )
  PunctuationClose
  /// `"Pi"` initial quotation marks,
  /// e.g. U+201C "Left Double Quotation Mark" ( “ )
  PunctuationInitial
  /// `"Pf"` final quotation marks,
  /// e.g. U+201D "Right Double Quotation Mark" ( ” )
  PunctuationFinal
  /// `"Po"` punctuation marks of other type,
  /// e.g. U+0021 "Exclamation Mark" ( ! )
  PunctuationOther

  // Symbols:
  /// `"Sm"` symbols of mathematical use,
  /// e.g. U+002B "Plus Sign" ( + )
  SymbolMath
  /// `"Sc"` currency signs,
  /// e.g. U+0024 "Dollar Sign" ( $ )
  SymbolCurrency
  /// `"Sk"` non-letterlike modifier symbol,
  /// e.g. U+005E "Circumflex Accent" ( ^ )
  SymbolModifier
  /// `"So"` symbol of other type,
  /// e.g. U+2B50 "White Medium Star" ( ⭐ )
  SymbolOther

  // Separators:
  /// `"Zs"` space characters (of various non-zero widths),
  /// e.g. U+0020 "Space" ( )
  SeparatorSpace
  /// `"Zl"` only U+2028 "Line Separator" (LSEP)
  SeparatorLine
  /// `"Zp"` only U+2029 "Paragraph Separator" (PSEP)
  SeparatorParagraph

  // Others:
  /// `"Cc"` C0 or C1 control codes,
  /// e.g. U+0007 "Alert" (BEL)
  Control
  /// `"Cf"` format control characters,
  /// e.g. U+00AD "Soft Hyphen" (SHY)
  Format
  /// `"Cs"` surrogate code points
  Surrogate
  /// `"Co"` private-use characters
  PrivateUse
  /// `"Cn"` reserved unassigned code points or noncharacters
  Unassigned
}

/// A list of all General Categories.
pub const list = [
  // Letters:
  LetterUppercase,
  LetterLowercase,
  LetterTitlecase,
  LetterModifier,
  LetterOther,
  // Marks:
  MarkNonspacing,
  MarkSpacing,
  MarkEnclosing,
  // Numbers:
  NumberDecimal,
  NumberLetter,
  NumberOther,
  // Punctuations:
  PunctuationConnector,
  PunctuationDash,
  PunctuationOpen,
  PunctuationClose,
  PunctuationInitial,
  PunctuationFinal,
  PunctuationOther,
  // Symbols:
  SymbolMath,
  SymbolCurrency,
  SymbolModifier,
  SymbolOther,
  // Separators:
  SeparatorSpace,
  SeparatorLine,
  SeparatorParagraph,
  // Others:
  Control,
  Format,
  Surrogate,
  PrivateUse,
  Unassigned,
]

/// Converts a name `String` to a [`GeneralCategory`](#GeneralCategory) value,
/// category's name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// assert category.from_name("Lu") == Ok(category.LetterUppercase)
/// assert category.from_name("Uppercase Letter") == Ok(category.LetterUppercase)
/// ```
///
pub fn from_name(str: String) -> Result(GeneralCategory, Nil) {
  case internal.comparable_property(str) {
    // From short name:
    // - Letters:
    "lu" -> Ok(LetterUppercase)
    "ll" -> Ok(LetterLowercase)
    "lt" -> Ok(LetterTitlecase)
    "lm" -> Ok(LetterModifier)
    "lo" -> Ok(LetterOther)
    // - Marks:
    "mn" -> Ok(MarkNonspacing)
    "mc" -> Ok(MarkSpacing)
    "me" -> Ok(MarkEnclosing)
    // - Numbers:
    "nd" -> Ok(NumberDecimal)
    "nl" -> Ok(NumberLetter)
    "no" -> Ok(NumberOther)
    // - Punctuations:
    "pc" -> Ok(PunctuationConnector)
    "pd" -> Ok(PunctuationDash)
    "ps" -> Ok(PunctuationOpen)
    "pe" -> Ok(PunctuationClose)
    "pi" -> Ok(PunctuationInitial)
    "pf" -> Ok(PunctuationFinal)
    "po" -> Ok(PunctuationOther)
    // - Symbols:
    "sm" -> Ok(SymbolMath)
    "sc" -> Ok(SymbolCurrency)
    "sk" -> Ok(SymbolModifier)
    "so" -> Ok(SymbolOther)
    // - Separators:
    "zs" -> Ok(SeparatorSpace)
    "zl" -> Ok(SeparatorLine)
    "zp" -> Ok(SeparatorParagraph)
    // - Others:
    "cc" -> Ok(Control)
    "cf" -> Ok(Format)
    "cs" -> Ok(Surrogate)
    "co" -> Ok(PrivateUse)
    "cn" -> Ok(Unassigned)
    // From long name:
    // - Letters:
    "uppercaseletter" -> Ok(LetterUppercase)
    "lowercaseletter" -> Ok(LetterLowercase)
    "titlecaseletter" -> Ok(LetterTitlecase)
    "modifierletter" -> Ok(LetterModifier)
    "otherletter" -> Ok(LetterOther)
    // - Marks:
    "nonspacingmark" -> Ok(MarkNonspacing)
    "spacingmark" -> Ok(MarkSpacing)
    "enclosingmark" -> Ok(MarkEnclosing)
    // - Numbers:
    "decimalnumber" -> Ok(NumberDecimal)
    "letternumber" -> Ok(NumberLetter)
    "othernumber" -> Ok(NumberOther)
    // - Punctuations:
    "connectorpunctuation" -> Ok(PunctuationConnector)
    "dashpunctuation" -> Ok(PunctuationDash)
    "openpunctuation" -> Ok(PunctuationOpen)
    "closepunctuation" -> Ok(PunctuationClose)
    "initialpunctuation" -> Ok(PunctuationInitial)
    "finalpunctuation" -> Ok(PunctuationFinal)
    "otherpunctuation" -> Ok(PunctuationOther)
    // - Symbols:
    "mathsymbol" -> Ok(SymbolMath)
    "currencysymbol" -> Ok(SymbolCurrency)
    "modifiersymbol" -> Ok(SymbolModifier)
    "othersymbol" -> Ok(SymbolOther)
    // - Separators:
    "spaceseparator" -> Ok(SeparatorSpace)
    "lineseparator" -> Ok(SeparatorLine)
    "paragraphseparator" -> Ok(SeparatorParagraph)
    // - Others:
    "control" -> Ok(Control)
    "format" -> Ok(Format)
    "surrogate" -> Ok(Surrogate)
    "privateuse" -> Ok(PrivateUse)
    "unassigned" -> Ok(Unassigned)

    _ -> Error(Nil)
  }
}

/// Returns the short name `String` of a [`GeneralCategory`](#GeneralCategory).
///
/// ## Examples
///
/// ```gleam
/// assert category.to_short_name(category.LetterUppercase) == "Lu"
///
/// assert category.to_short_name(category.Unassigned) == "Cn"
///
/// assert category.to_short_name(category.SymbolMath) == "Sm"
/// ```
///
pub fn to_short_name(category: GeneralCategory) -> String {
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
    PunctuationInitial -> "Pi"
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

/// Returns the long name `String` of a [`GeneralCategory`](#GeneralCategory).
///
/// ## Examples
///
/// ```gleam
/// assert category.to_long_name(category.LetterUppercase) == "Uppercase_Letter"
///
/// assert category.to_long_name(category.Unassigned) == "Unassigned"
///
/// assert category.to_long_name(category.SymbolMath) == "Math_Symbol"
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
    PunctuationInitial -> "Initial_Punctuation"
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

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is assigned to abstract characters (not `Surrogate` or `Unassigned`).
///
/// ## Examples
///
/// ```gleam
/// assert category.is_assigned(category.LetterLowercase)
/// assert !category.is_assigned(category.Surrogate)
/// assert !category.is_assigned(category.Unassigned)
/// ```
///
pub fn is_assigned(category: GeneralCategory) -> Bool {
  category != Surrogate && category != Unassigned
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a cased letter category (uppercase, lowercase, or titlecase).
///
/// ## Examples
///
/// ```gleam
/// assert category.is_cased_letter(category.LetterLowercase)
/// assert !category.is_cased_letter(category.LetterOther)
/// ```
///
pub fn is_cased_letter(category: GeneralCategory) -> Bool {
  category == LetterUppercase
  || category == LetterLowercase
  || category == LetterTitlecase
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a letter category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_letter(category.LetterLowercase)
/// assert !category.is_letter(category.NumberDecimal)
/// ```
///
pub fn is_letter(category: GeneralCategory) -> Bool {
  is_cased_letter(category)
  || category == LetterModifier
  || category == LetterOther
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a mark category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_letter(category.MarkSpacing)
/// assert !category.is_letter(category.NumberDecimal)
/// ```
///
pub fn is_mark(category: GeneralCategory) -> Bool {
  category == MarkNonspacing
  || category == MarkSpacing
  || category == MarkEnclosing
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a number category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_letter(category.NumberDecimal)
/// assert !category.is_letter(category.LetterLowercase)
/// ```
///
pub fn is_number(category: GeneralCategory) -> Bool {
  category == NumberDecimal
  || category == NumberLetter
  || category == NumberOther
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a punctuation category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_punctuation(category.PunctuationOther)
/// assert !category.is_punctuation(category.NumberDecimal)
/// ```
///
pub fn is_punctuation(category: GeneralCategory) -> Bool {
  category == PunctuationConnector
  || category == PunctuationDash
  || category == PunctuationOpen
  || category == PunctuationClose
  || category == PunctuationInitial
  || category == PunctuationFinal
  || category == PunctuationOther
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a quotation category (initial or final punctuation).
/// Note that not all quotation marks are in those categories.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_quotation(category.PunctuationInitial)
/// assert !category.is_quotation(category.PunctuationOpen)
/// ```
///
pub fn is_quotation(category: GeneralCategory) -> Bool {
  category == PunctuationInitial || category == PunctuationFinal
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a symbol category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_symbol(category.SymbolCurrency)
/// assert !category.is_symbol(category.NumberDecimal)
/// ```
///
pub fn is_symbol(category: GeneralCategory) -> Bool {
  category == SymbolMath
  || category == SymbolCurrency
  || category == SymbolModifier
  || category == SymbolOther
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a separator category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_separator(category.SeparatorSpace)
/// assert !category.is_separator(category.NumberDecimal)
/// ```
///
pub fn is_separator(category: GeneralCategory) -> Bool {
  category == SeparatorSpace
  || category == SeparatorLine
  || category == SeparatorParagraph
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is an "other" category.
///
/// ## Examples
///
/// ```gleam
/// assert category.is_other(category.Control)
/// assert !category.is_other(category.NumberDecimal)
/// ```
///
pub fn is_other(category: GeneralCategory) -> Bool {
  category == Control
  || category == Format
  || category == Surrogate
  || category == PrivateUse
  || category == Unassigned
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a "Graphic" Basic Type
/// (letters, marks, numbers, punctuations, symbols, and spaces).
///
/// ## Examples
///
/// ```gleam
/// assert category.is_graphic(category.LetterLowercase)
/// assert !category.is_graphic(category.Control)
/// ```
///
pub fn is_graphic(category: GeneralCategory) -> Bool {
  is_letter(category)
  || is_mark(category)
  || is_number(category)
  || is_punctuation(category)
  || is_symbol(category)
  || category == SeparatorSpace
}

/// Returns `True` if the [`GeneralCategory`](#GeneralCategory) provided
/// is a "Format" Basic Type
/// (invisible but affects neighboring characters).
///
/// ## Examples
///
/// ```gleam
/// assert category.is_format(category.Format)
/// assert category.is_format(category.SeparatorLine)
/// assert category.is_format(category.SeparatorParagraph)
/// assert !category.is_format(category.Control)
/// ```
///
pub fn is_format(category: GeneralCategory) -> Bool {
  category == Format
  || category == SeparatorLine
  || category == SeparatorParagraph
}
