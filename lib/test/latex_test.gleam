import chartable/latex
import chartable/latex/math_type

pub fn unimath_from_grapheme_test() {
  assert latex.unimath_from_grapheme("\u{22C6}") == ["\\star"]
  assert latex.unimath_from_grapheme("⭐") == ["\\medwhitestar"]
  assert latex.unimath_from_grapheme("𝔄") == ["\\mfrakA"]
  assert latex.unimath_from_grapheme("𝔞") == ["\\mfraka"]

  assert latex.unimath_from_grapheme("&") == ["\\mathampersand"]
  assert latex.unimath_from_grapheme("\u{0302}") == ["\\hat", "\\widehat"]
  assert latex.unimath_from_grapheme("Γ") == ["\\mupGamma"]
  assert latex.unimath_from_grapheme("\u{20E8}") == ["\\threeunderdot"]
  assert latex.unimath_from_grapheme("\u{20EF}") == ["\\underrightarrow"]
  assert latex.unimath_from_grapheme("\u{0338}") == ["\\notaccent"]
  assert latex.unimath_from_grapheme("×") == ["\\times"]
  assert latex.unimath_from_grapheme("=") == ["\\equal"]
  assert latex.unimath_from_grapheme("∑") == ["\\sum"]
  assert latex.unimath_from_grapheme("√") == ["\\sqrt", "\\surd"]
  assert latex.unimath_from_grapheme("{") == ["\\lbrace"]
  assert latex.unimath_from_grapheme("}") == ["\\rbrace"]
  assert latex.unimath_from_grapheme("|") == ["\\vert"]
  assert latex.unimath_from_grapheme("⎴") == ["\\overbracket"]
  assert latex.unimath_from_grapheme("⎵") == ["\\underbracket"]
  assert latex.unimath_from_grapheme(":") == ["\\mathcolon"]
}

pub fn unimath_to_grapheme_test() {
  assert latex.unimath_to_grapheme("star") == Ok("\u{22C6}")
  assert latex.unimath_to_grapheme("medwhitestar") == Ok("⭐")
  assert latex.unimath_to_grapheme("mfrakA") == Ok("𝔄")
  assert latex.unimath_to_grapheme("mfraka") == Ok("𝔞")

  assert latex.unimath_to_grapheme("mathampersand") == Ok("&")
  assert latex.unimath_to_grapheme("mupGamma") == Ok("Γ")
  assert latex.unimath_to_grapheme("hat") == Ok("\u{0302}")
  assert latex.unimath_to_grapheme("widehat") == Ok("\u{0302}")
  assert latex.unimath_to_grapheme("threeunderdot") == Ok("\u{20E8}")
  assert latex.unimath_to_grapheme("underrightarrow") == Ok("\u{20EF}")
  assert latex.unimath_to_grapheme("notaccent") == Ok("\u{0338}")
  assert latex.unimath_to_grapheme("times") == Ok("×")
  assert latex.unimath_to_grapheme("equal") == Ok("=")
  assert latex.unimath_to_grapheme("sum") == Ok("∑")
  assert latex.unimath_to_grapheme("sqrt") == Ok("√")
  assert latex.unimath_to_grapheme("lbrace") == Ok("{")
  assert latex.unimath_to_grapheme("rbrace") == Ok("}")
  assert latex.unimath_to_grapheme("vert") == Ok("|")
  assert latex.unimath_to_grapheme("overbracket") == Ok("⎴")
  assert latex.unimath_to_grapheme("underbracket") == Ok("⎵")
  assert latex.unimath_to_grapheme("mathcolon") == Ok(":")
}

pub fn unimath_to_math_type_test() {
  assert latex.unimath_to_math_type("mathampersand") == Ok(math_type.Ordinary)
  assert latex.unimath_to_math_type("mupGamma") == Ok(math_type.Alphabetic)
  assert latex.unimath_to_math_type("hat") == Ok(math_type.Accent)
  assert latex.unimath_to_math_type("widehat") == Ok(math_type.AcentWide)
  assert latex.unimath_to_math_type("threeunderdot")
    == Ok(math_type.BottomAccent)
  assert latex.unimath_to_math_type("underrightarrow")
    == Ok(math_type.BottomAccentWide)
  assert latex.unimath_to_math_type("notaccent") == Ok(math_type.AccentOverlay)
  assert latex.unimath_to_math_type("times") == Ok(math_type.BinaryOperation)
  assert latex.unimath_to_math_type("equal") == Ok(math_type.Relation)
  assert latex.unimath_to_math_type("sum") == Ok(math_type.LargeOperator)
  // assert latex.unimath_to_math_type("sqrt") == Ok(math_type.Radical)
  assert latex.unimath_to_math_type("lbrace") == Ok(math_type.Opening)
  assert latex.unimath_to_math_type("rbrace") == Ok(math_type.Closing)
  assert latex.unimath_to_math_type("vert") == Ok(math_type.Fencing)
  assert latex.unimath_to_math_type("overbracket") == Ok(math_type.Over)
  assert latex.unimath_to_math_type("underbracket") == Ok(math_type.Under)
  assert latex.unimath_to_math_type("mathcolon") == Ok(math_type.Punctuation)
}
