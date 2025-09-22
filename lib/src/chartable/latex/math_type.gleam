/// Math Type used in `\DeclareMathSymbol`, see
/// [fntguide](https://www.ctan.org/pkg/fntguide)
/// part 3.6 "declaring math symbols", and
/// [LUCR `category2mathtype.txt`](https://milde.users.sourceforge.net/LUCR/Math/data/category2mathtype.txt)
///
/// ```gleam
/// // NOTE: LaTeX3 includes many new math types not listed in the links above
/// ```
pub type MathType {
  /// `\mathord`: ordinary non-alphabetic characters,
  /// e.g. U+0026 `\mathampersand` ( & )
  Ordinary
  /// `\mathalpha`: alphabetic characters,
  /// e.g. U+0393 `\mupGamma` ( Γ )
  Alphabetic
  /// `\mathaccent`: top accents & diacritics,
  /// e.g. U+0302 `\hat` ( ◌̂ )
  Accent
  /// `\mathaccentwide`: wide top accents & diacritics,
  /// e.g. U+0302 `\widehat` ( ◌̂ )
  AcentWide
  /// `\mathbotaccent`: bottom accents & diacritics,
  /// e.g. U+20E8 `\threeunderdot` ( ◌⃨ )
  BottomAccent
  /// `\mathbotaccentwide`: wide bottom accents & diacritics,
  /// e.g. U+20EF `\underrightarrow` ( ◌⃯ )
  BottomAccentWide
  /// `\mathaccentoverlay`: overlay accents & diacritics,
  /// e.g. U+0338 `\notaccent` ( ◌̸ )
  AccentOverlay
  /// `\mathbin`: binary operations,
  /// e.g. U+00D7 `\times` ( × )
  BinaryOperation
  /// `\mathrel`: relations,
  /// e.g. U+003D `\equal` ( = )
  Relation
  /// `\mathop`: large operator,
  /// e.g. U+2211 `\sum` ( ∑ )
  LargeOperator
  /// `\mathradical`: radical signs,
  /// e.g. U+221A `\sqrt` ( √ )
  Radical
  /// `\mathopen`: opening delimiters,
  /// e.g. U+007B `\lbrace` ( { )
  Opening
  /// `\mathclose`: closing delimiters,
  /// e.g. U+007D `\rbrace` ( } )
  Closing
  /// `\mathfence`: fencing delimiters,
  /// e.g. U+007C `\vert` ( | )
  Fencing
  /// `\mathover`: over,
  /// e.g. U+23B4 `\overbracket` ( ⎴ )
  Over
  /// `\mathunder`: under,
  /// e.g. U+23B5 `\underbracket` ( ⎵ )
  Under
  /// `\mathpunct`: punctuations,
  /// e.g. U+003A `\mathcolon` ( : )
  Punctuation
}

pub fn from_tex(str: String) -> Result(MathType, Nil) {
  case str {
    "\\mathord" -> Ok(Ordinary)
    "\\mathalpha" -> Ok(Alphabetic)
    "\\mathaccent" -> Ok(Accent)
    "\\mathaccentwide" -> Ok(AcentWide)
    "\\mathbotaccent" -> Ok(BottomAccent)
    "\\mathbotaccentwide" -> Ok(BottomAccentWide)
    "\\mathaccentoverlay" -> Ok(AccentOverlay)
    "\\mathbin" -> Ok(BinaryOperation)
    "\\mathrel" -> Ok(Relation)
    "\\mathop" -> Ok(LargeOperator)
    "\\mathradical" -> Ok(Radical)
    "\\mathopen" -> Ok(Opening)
    "\\mathclose" -> Ok(Closing)
    "\\mathfence" -> Ok(Fencing)
    "\\mathover" -> Ok(Over)
    "\\mathunder" -> Ok(Under)
    "\\mathpunct" -> Ok(Punctuation)
    _ -> Error(Nil)
  }
}

pub fn to_tex(math_type: MathType) -> String {
  case math_type {
    Ordinary -> "\\mathord"
    Alphabetic -> "\\mathalpha"
    Accent -> "\\mathaccent"
    AcentWide -> "\\mathaccentwide"
    BottomAccent -> "\\mathbotaccent"
    BottomAccentWide -> "\\mathbotaccentwide"
    AccentOverlay -> "\\mathaccentoverlay"
    BinaryOperation -> "\\mathbin"
    Relation -> "\\mathrel"
    LargeOperator -> "\\mathop"
    Radical -> "\\mathradical"
    Opening -> "\\mathopen"
    Closing -> "\\mathclose"
    Fencing -> "\\mathfence"
    Over -> "\\mathover"
    Under -> "\\mathunder"
    Punctuation -> "\\mathpunct"
  }
}
// pub fn from_int(int: Int) -> Result(MathType, Nil) {
//   case int {
//     0 -> Ok(Ordinary)
//     1 -> Ok(LargeOperator)
//     2 -> Ok(BinaryOperation)
//     3 -> Ok(Relation)
//     4 -> Ok(Opening)
//     5 -> Ok(Closing)
//     6 -> Ok(Punctuation)
//     7 -> Ok(Alphabetic)
//     _ -> Error(Nil)
//   }
// }
//
// pub fn to_int(math_type: MathType) -> Int {
//   case math_type {
//     Ordinary -> 0
//     LargeOperator -> 1
//     BinaryOperation -> 2
//     Relation -> 3
//     Opening -> 4
//     Closing -> 5
//     Punctuation -> 6
//     Alphabetic -> 7
//   }
// }
