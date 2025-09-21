//// [General Category Values](https://www.unicode.org/reports/tr44/#General_Category_Values):
//// provides a general classification of every code point,
//// many characters have multiples uses wich are not captured by
//// this simple categories (Latin letters may be used as numerals).

import chartable/internal

pub type GeneralCategory {
  Letter(Letter)
  Mark(Mark)
  Number(Number)
  Punctuation(Punctuation)
  Symbol(Symbol)
  Separator(Separator)
  Other(Other)
}

pub type Letter {
  /// `"Lu"` uppercase letters,
  /// e.g. U+0041 "Latin Capital Letter A" ( A )
  UppercaseLetter
  /// `"Ll"` lowercase letters,
  /// e.g. U+0061 "Latin Small Letter A" ( a )
  LowercaseLetter
  /// `"Lt"` digraphs encoded as a single character, with first part uppercase,
  /// e.g. U+01F2 "Latin Capital Letter D with Small Letter Z" ( ǲ )
  TitlecaseLetter
  /// `"Lm"` modifier letters,
  /// e.g. U+02B0 "Modifier Letter Small H" ( ʰ )
  ModifierLetter
  /// `"Lo"` other letters, including syllables and ideographs,
  /// e.g. U+661F "CJK Ideograph for Star" ( 星 )
  OtherLetter
}

pub type Mark {
  /// `"Mn"` nonspacing combining marks (zero advance width),
  /// e.g. U+0301 "Combining Acute Accent" ( ◌́ )
  NonspacingMark
  /// `"Mc"` spacing combining marks (positive advance width),
  /// e.g. U+0903 "Devanagari Sign Visarga" ( ◌ः )
  SpacingMark
  /// `"Me"` enclosing combining marks,
  /// e.g. U+20E0 "Combining Enclosing Circle Backslash" ( ◌⃠ )
  EnclosingMark
}

pub type Number {
  /// `"Nd"` decimal digits,
  /// e.g. U+0032 "Digit Two" ( 2 )
  DecimalNumber
  /// `"Nl"` letterlike numeric characters,
  /// e.g. U+2162 "Roman Numeral Three" ( Ⅲ )
  LetterNumber
  /// `"No"` numeric character of other type,
  /// e.g. U+00BD "Vulgar Fraction One Half" ( ½ )
  OtherNumber
}

pub type Punctuation {
  /// `"Pc"` connecting punctuation marks,
  /// e.g. U+2040 "Character Tie" (◌⁀◌)
  ConnectorPunctuation
  /// `"Pd"` dash or hyphen punctuation marks,
  /// e.g. U+2013 "En Dash" ( – )
  DashPunctuation
  /// `"Ps"` opening/starting punctuation marks (of a pair),
  /// e.g. U+007B "Left Curly Bracket" ( { )
  OpenPunctuation
  /// `"Pe"` closing/ending punctuation marks (of a pair),
  /// e.g. U+007D "Right Curly Bracket" ( } )
  ClosePunctuation
  /// `"Pi"` initial quotation marks,
  /// e.g. U+201C "Left Double Quotation Mark" ( “ )
  InitialPunctuation
  /// `"Pf"` final quotation marks,
  /// e.g. U+201D "Right Double Quotation Mark" ( ” )
  FinalPunctuation
  /// `"Po"` punctuation marks of other type,
  /// e.g. U+0021 "Exclamation Mark" ( ! )
  OtherPunctuation
}

pub type Symbol {
  /// `"Sm"` symbols of mathematical use,
  /// e.g. U+002B "Plus Sign" ( + )
  MathSymbol
  /// `"Sc"` currency signs,
  /// e.g. U+0024 "Dollar Sign" ( $ )
  CurrencySymbol
  /// `"Sk"` non-letterlike modifier symbol,
  /// e.g. U+005E "Circumflex Accent" ( ^ )
  ModifierSymbol
  /// `"So"` symbol of other type,
  /// e.g. U+2B50 "White Medium Star" ( ⭐ )
  OtherSymbol
}

pub type Separator {
  /// `"Zs"` space characters (of various non-zero widths),
  /// e.g. U+0020 "Space" ( )
  SpaceSeparator
  /// `"Zl"` only U+2028 "Line Separator" (LSEP)
  LineSeparator
  /// `"Zp"` only U+2029 "Paragraph Separator" (PSEP)
  ParagraphSeparator
}

pub type Other {
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
  Letter(UppercaseLetter),
  Letter(LowercaseLetter),
  Letter(TitlecaseLetter),
  Letter(ModifierLetter),
  Letter(OtherLetter),
  // Marks:
  Mark(NonspacingMark),
  Mark(SpacingMark),
  Mark(EnclosingMark),
  // Numbers:
  Number(DecimalNumber),
  Number(LetterNumber),
  Number(OtherNumber),
  // Punctuations:
  Punctuation(ConnectorPunctuation),
  Punctuation(DashPunctuation),
  Punctuation(OpenPunctuation),
  Punctuation(ClosePunctuation),
  Punctuation(InitialPunctuation),
  Punctuation(FinalPunctuation),
  Punctuation(OtherPunctuation),
  // Symbols:
  Symbol(MathSymbol),
  Symbol(CurrencySymbol),
  Symbol(ModifierSymbol),
  Symbol(OtherSymbol),
  // Separators:
  Separator(SpaceSeparator),
  Separator(LineSeparator),
  Separator(ParagraphSeparator),
  // Others:
  Other(Control),
  Other(Format),
  Other(Surrogate),
  Other(PrivateUse),
  Other(Unassigned),
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
    "lu" -> Ok(Letter(UppercaseLetter))
    "ll" -> Ok(Letter(LowercaseLetter))
    "lt" -> Ok(Letter(TitlecaseLetter))
    "lm" -> Ok(Letter(ModifierLetter))
    "lo" -> Ok(Letter(OtherLetter))
    // - Marks:
    "mn" -> Ok(Mark(NonspacingMark))
    "mc" -> Ok(Mark(SpacingMark))
    "me" -> Ok(Mark(EnclosingMark))
    // - Numbers:
    "nd" -> Ok(Number(DecimalNumber))
    "nl" -> Ok(Number(LetterNumber))
    "no" -> Ok(Number(OtherNumber))
    // - Punctuations:
    "pc" -> Ok(Punctuation(ConnectorPunctuation))
    "pd" -> Ok(Punctuation(DashPunctuation))
    "ps" -> Ok(Punctuation(OpenPunctuation))
    "pe" -> Ok(Punctuation(ClosePunctuation))
    "pi" -> Ok(Punctuation(InitialPunctuation))
    "pf" -> Ok(Punctuation(FinalPunctuation))
    "po" -> Ok(Punctuation(OtherPunctuation))
    // - Symbols:
    "sm" -> Ok(Symbol(MathSymbol))
    "sc" -> Ok(Symbol(CurrencySymbol))
    "sk" -> Ok(Symbol(ModifierSymbol))
    "so" -> Ok(Symbol(OtherSymbol))
    // - Separators:
    "zs" -> Ok(Separator(SpaceSeparator))
    "zl" -> Ok(Separator(LineSeparator))
    "zp" -> Ok(Separator(ParagraphSeparator))
    // - Others:
    "cc" -> Ok(Other(Control))
    "cf" -> Ok(Other(Format))
    "cs" -> Ok(Other(Surrogate))
    "co" -> Ok(Other(PrivateUse))
    "cn" -> Ok(Other(Unassigned))
    // From long name:
    // - Letters:
    "uppercaseletter" -> Ok(Letter(UppercaseLetter))
    "lowercaseletter" -> Ok(Letter(LowercaseLetter))
    "titlecaseletter" -> Ok(Letter(TitlecaseLetter))
    "modifierletter" -> Ok(Letter(ModifierLetter))
    "otherletter" -> Ok(Letter(OtherLetter))
    // - Marks:
    "nonspacingmark" -> Ok(Mark(NonspacingMark))
    "spacingmark" -> Ok(Mark(SpacingMark))
    "enclosingmark" -> Ok(Mark(EnclosingMark))
    // - Numbers:
    "decimalnumber" -> Ok(Number(DecimalNumber))
    "letternumber" -> Ok(Number(LetterNumber))
    "othernumber" -> Ok(Number(OtherNumber))
    // - Punctuations:
    "connectorpunctuation" -> Ok(Punctuation(ConnectorPunctuation))
    "dashpunctuation" -> Ok(Punctuation(DashPunctuation))
    "openpunctuation" -> Ok(Punctuation(OpenPunctuation))
    "closepunctuation" -> Ok(Punctuation(ClosePunctuation))
    "initialpunctuation" -> Ok(Punctuation(InitialPunctuation))
    "finalpunctuation" -> Ok(Punctuation(FinalPunctuation))
    "otherpunctuation" -> Ok(Punctuation(OtherPunctuation))
    // - Symbols:
    "mathsymbol" -> Ok(Symbol(MathSymbol))
    "currencysymbol" -> Ok(Symbol(CurrencySymbol))
    "modifiersymbol" -> Ok(Symbol(ModifierSymbol))
    "othersymbol" -> Ok(Symbol(OtherSymbol))
    // - Separators:
    "spaceseparator" -> Ok(Separator(SpaceSeparator))
    "lineseparator" -> Ok(Separator(LineSeparator))
    "paragraphseparator" -> Ok(Separator(ParagraphSeparator))
    // - Others:
    "control" -> Ok(Other(Control))
    "format" -> Ok(Other(Format))
    "surrogate" -> Ok(Other(Surrogate))
    "privateuse" -> Ok(Other(PrivateUse))
    "unassigned" -> Ok(Other(Unassigned))

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
    Letter(UppercaseLetter) -> "Lu"
    Letter(LowercaseLetter) -> "Ll"
    Letter(TitlecaseLetter) -> "Lt"
    Letter(ModifierLetter) -> "Lm"
    Letter(OtherLetter) -> "Lo"
    // Marks:
    Mark(NonspacingMark) -> "Mn"
    Mark(SpacingMark) -> "Mc"
    Mark(EnclosingMark) -> "Me"
    // Numbers:
    Number(DecimalNumber) -> "Nd"
    Number(LetterNumber) -> "Nl"
    Number(OtherNumber) -> "No"
    // Punctuations:
    Punctuation(ConnectorPunctuation) -> "Pc"
    Punctuation(DashPunctuation) -> "Pd"
    Punctuation(OpenPunctuation) -> "Ps"
    Punctuation(ClosePunctuation) -> "Pe"
    Punctuation(InitialPunctuation) -> "Pi"
    Punctuation(FinalPunctuation) -> "Pf"
    Punctuation(OtherPunctuation) -> "Po"
    // Symbols:
    Symbol(MathSymbol) -> "Sm"
    Symbol(CurrencySymbol) -> "Sc"
    Symbol(ModifierSymbol) -> "Sk"
    Symbol(OtherSymbol) -> "So"
    // Separators:
    Separator(SpaceSeparator) -> "Zs"
    Separator(LineSeparator) -> "Zl"
    Separator(ParagraphSeparator) -> "Zp"
    // Others:
    Other(Control) -> "Cc"
    Other(Format) -> "Cf"
    Other(Surrogate) -> "Cs"
    Other(PrivateUse) -> "Co"
    Other(Unassigned) -> "Cn"
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
    Letter(UppercaseLetter) -> "Uppercase_Letter"
    Letter(LowercaseLetter) -> "Lowercase_Letter"
    Letter(TitlecaseLetter) -> "Titlecase_Letter"
    Letter(ModifierLetter) -> "Modifier_Letter"
    Letter(OtherLetter) -> "Other_Letter"
    // Marks:
    Mark(NonspacingMark) -> "Nonspacing_Mark"
    Mark(SpacingMark) -> "Spacing_Mark"
    Mark(EnclosingMark) -> "Enclosing_Mark"
    // Numbers:
    Number(DecimalNumber) -> "Decimal_Number"
    Number(LetterNumber) -> "Letter_Number"
    Number(OtherNumber) -> "Other_Number"
    // Punctuations:
    Punctuation(ConnectorPunctuation) -> "Connector_Punctuation"
    Punctuation(DashPunctuation) -> "Dash_Punctuation"
    Punctuation(OpenPunctuation) -> "Open_Punctuation"
    Punctuation(ClosePunctuation) -> "Close_Punctuation"
    Punctuation(InitialPunctuation) -> "Initial_Punctuation"
    Punctuation(FinalPunctuation) -> "Final_Punctuation"
    Punctuation(OtherPunctuation) -> "Other_Punctuation"
    // Symbols:
    Symbol(MathSymbol) -> "Math_Symbol"
    Symbol(CurrencySymbol) -> "Currency_Symbol"
    Symbol(ModifierSymbol) -> "Modifier_Symbol"
    Symbol(OtherSymbol) -> "Other_Symbol"
    // Separators:
    Separator(SpaceSeparator) -> "Space_Separator"
    Separator(LineSeparator) -> "Line_Separator"
    Separator(ParagraphSeparator) -> "Paragraph_Separator"
    // Others:
    Other(Control) -> "Control"
    Other(Format) -> "Format"
    Other(Surrogate) -> "Surrogate"
    Other(PrivateUse) -> "Private_Use"
    Other(Unassigned) -> "Unassigned"
  }
}

/// Returns `True` if the [`Letter`](#Letter) category provided
/// is a cased letter category (uppercase, lowercase, or titlecase).
///
/// ## Examples
///
/// ```gleam
/// assert category.is_cased_letter(category.LetterLowercase)
/// assert !category.is_cased_letter(category.LetterOther)
/// ```
///
pub fn is_cased_letter(category: Letter) -> Bool {
  category == UppercaseLetter
  || category == LowercaseLetter
  || category == TitlecaseLetter
}

/// Returns `True` if the [`Punctuation`](#Punctuation) category provided
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
pub fn is_quotation(category: Punctuation) -> Bool {
  category == InitialPunctuation || category == FinalPunctuation
}
