import chartable/latex
import chartable/latex/math_type
import gleam/result
import gleam/string

pub fn catcode_test() {
  let catcode_from_grapheme = fn(g) {
    case string.to_utf_codepoints(g) {
      [cp] -> latex.catcode_from_codepoint(cp) |> latex.catcode_to_int
      _ -> 12
    }
  }
  assert catcode_from_grapheme("\\") == 0
  assert catcode_from_grapheme("{") == 1
  assert catcode_from_grapheme("}") == 2
  assert catcode_from_grapheme("$") == 3
  assert catcode_from_grapheme("&") == 4
  assert catcode_from_grapheme("\r") == 5
  // assert catcode_from_grapheme("\n") == 5
  assert catcode_from_grapheme("#") == 6
  assert catcode_from_grapheme("^") == 7
  assert catcode_from_grapheme("\u{0B}") == 7
  assert catcode_from_grapheme("_") == 8
  assert catcode_from_grapheme("\u{01}") == 8
  assert catcode_from_grapheme("\u{00}") == 9
  assert catcode_from_grapheme(" ") == 10
  assert catcode_from_grapheme("\t") == 10
  assert catcode_from_grapheme("A") == 11
  assert catcode_from_grapheme("G") == 11
  assert catcode_from_grapheme("Z") == 11
  assert catcode_from_grapheme("a") == 11
  assert catcode_from_grapheme("g") == 11
  assert catcode_from_grapheme("z") == 11
  assert catcode_from_grapheme("@") == 12
  assert catcode_from_grapheme("Γ") == 12
  assert catcode_from_grapheme("⭐") == 12
  assert catcode_from_grapheme("~") == 13
  assert catcode_from_grapheme("\f") == 13
  assert catcode_from_grapheme("%") == 14
  assert catcode_from_grapheme("\u{7F}") == 15
}

pub fn char_escape_test() {
  let assert Ok(cp) = string.utf_codepoint(65)
  assert latex.char_escape(cp) == "\\char65"
  let assert Ok(cp) = string.utf_codepoint(0x2B50)
  assert latex.char_escape(cp) == "\\char11088"
}

pub fn any_to_grapheme_test() {
  assert latex.text_to_grapheme("`") == Ok("\u{2018}")
  assert latex.math_to_grapheme("`") == Ok("\u{2018}")
  assert latex.text_to_grapheme("\\space") == Ok(" ")
  assert latex.math_to_grapheme("\\space") == Ok(" ")
}

pub fn char_to_grapheme_test() {
  assert latex.text_to_grapheme("\\char65") == Ok("A")
  assert latex.math_to_grapheme("\\char65") == Ok("A")
  assert latex.text_to_grapheme("\\char11088") == Ok("⭐")
  assert latex.math_to_grapheme("\\char11088") == Ok("⭐")
}

pub fn text_to_grapheme_test() {
  assert latex.text_to_grapheme("~") == Ok("\u{00A0}")
  assert latex.text_to_grapheme("``") == Ok("“")
  assert latex.text_to_grapheme("''") == Ok("”")
  assert latex.text_to_grapheme("\\-") == Ok("\u{00AD}")
}

pub fn math_to_grapheme_test() {
  assert latex.math_to_grapheme("'") == Ok("′")
}

pub fn unimath_to_grapheme_test() {
  assert latex.math_to_grapheme("\\star") == Ok("\u{22C6}")
  assert latex.math_to_grapheme("\\medwhitestar") == Ok("⭐")
  assert latex.math_to_grapheme("\\mfrakA") == Ok("𝔄")
  assert latex.math_to_grapheme("\\mfraka") == Ok("𝔞")

  assert latex.math_to_grapheme("\\mathampersand") == Ok("&")
  assert latex.math_to_grapheme("\\mupGamma") == Ok("Γ")
  assert latex.math_to_grapheme("\\hat") == Ok("\u{0302}")
  assert latex.math_to_grapheme("\\widehat") == Ok("\u{0302}")
  assert latex.math_to_grapheme("\\threeunderdot") == Ok("\u{20E8}")
  assert latex.math_to_grapheme("\\underrightarrow") == Ok("\u{20EF}")
  assert latex.math_to_grapheme("\\notaccent") == Ok("\u{0338}")
  assert latex.math_to_grapheme("\\times") == Ok("×")
  assert latex.math_to_grapheme("\\equal") == Ok("=")
  assert latex.math_to_grapheme("\\sum") == Ok("∑")
  assert latex.math_to_grapheme("\\sqrt") == Ok("√")
  assert latex.math_to_grapheme("\\lbrace") == Ok("{")
  assert latex.math_to_grapheme("\\rbrace") == Ok("}")
  assert latex.math_to_grapheme("\\vert") == Ok("|")
  assert latex.math_to_grapheme("\\overbracket") == Ok("⎴")
  assert latex.math_to_grapheme("\\underbracket") == Ok("⎵")
  assert latex.math_to_grapheme("\\mathcolon") == Ok(":")
}

pub fn unimath_from_grapheme_test() {
  let unimath_from_grapheme = fn(grapheme) {
    case string.to_utf_codepoints(grapheme) {
      [cp] -> latex.unimath_from_codepoint(cp)
      _ -> []
    }
  }
  assert unimath_from_grapheme("\u{22C6}") == ["\\star"]
  assert unimath_from_grapheme("⭐") == ["\\medwhitestar"]
  assert unimath_from_grapheme("𝔄") == ["\\mfrakA"]
  assert unimath_from_grapheme("𝔞") == ["\\mfraka"]

  assert unimath_from_grapheme("&") == ["\\mathampersand"]
  assert unimath_from_grapheme("\u{0302}") == ["\\hat", "\\widehat"]
  assert unimath_from_grapheme("Γ") == ["\\mupGamma"]
  assert unimath_from_grapheme("\u{20E8}") == ["\\threeunderdot"]
  assert unimath_from_grapheme("\u{20EF}") == ["\\underrightarrow"]
  assert unimath_from_grapheme("\u{0338}") == ["\\notaccent"]
  assert unimath_from_grapheme("×") == ["\\times"]
  assert unimath_from_grapheme("=") == ["\\equal"]
  assert unimath_from_grapheme("∑") == ["\\sum"]
  assert unimath_from_grapheme("√") == ["\\sqrt", "\\surd"]
  assert unimath_from_grapheme("{") == ["\\lbrace"]
  assert unimath_from_grapheme("}") == ["\\rbrace"]
  assert unimath_from_grapheme("|") == ["\\vert"]
  assert unimath_from_grapheme("⎴") == ["\\overbracket"]
  assert unimath_from_grapheme("⎵") == ["\\underbracket"]
  assert unimath_from_grapheme(":") == ["\\mathcolon"]
}

pub fn unimath_to_math_type_test() {
  let math_type = fn(command) {
    use #(math_type, _) <- result.map(latex.unimath(command))
    math_type
  }
  assert math_type("mathampersand") == Ok(math_type.Ordinary)
  assert math_type("mupGamma") == Ok(math_type.Alphabetic)
  assert math_type("hat") == Ok(math_type.Accent)
  assert math_type("widehat") == Ok(math_type.AcentWide)
  assert math_type("threeunderdot") == Ok(math_type.BottomAccent)
  assert math_type("underrightarrow") == Ok(math_type.BottomAccentWide)
  assert math_type("notaccent") == Ok(math_type.AccentOverlay)
  assert math_type("times") == Ok(math_type.BinaryOperation)
  assert math_type("equal") == Ok(math_type.Relation)
  assert math_type("sum") == Ok(math_type.LargeOperator)
  // assert unimath_to_math_type("sqrt") == Ok(math_type.Radical)
  assert math_type("lbrace") == Ok(math_type.Opening)
  assert math_type("rbrace") == Ok(math_type.Closing)
  assert math_type("vert") == Ok(math_type.Fencing)
  assert math_type("overbracket") == Ok(math_type.Over)
  assert math_type("underbracket") == Ok(math_type.Under)
  assert math_type("mathcolon") == Ok(math_type.Punctuation)
}
