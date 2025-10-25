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

pub fn short_control_escape_test() {
  let short_control_escape = fn(str) {
    let assert [codepoint] = string.to_utf_codepoints(str)
    latex.short_control_escape(codepoint)
  }
  assert short_control_escape("!") == Ok("^^a")
  assert short_control_escape("a") == Ok("^^!")
  assert short_control_escape("M") == Ok("^^\r")
  assert short_control_escape("?") == Ok("^^\u{7F}")
  assert short_control_escape("@") == Ok("^^\u{00}")
  assert short_control_escape("^") == Ok("^^\u{1E}")
  assert short_control_escape("\r") == Ok("^^M")
  assert short_control_escape("\u{7F}") == Ok("^^?")
  assert short_control_escape("\u{00}") == Ok("^^@")
  assert short_control_escape("\u{1E}") == Ok("^^^")
}

pub fn long_control_escape_test() {
  let long_control_escape = fn(cp) {
    let assert Ok(codepoint) = string.utf_codepoint(cp)
    latex.long_control_escape(codepoint)
  }
  assert long_control_escape(0x100) == Error(Nil)
  assert long_control_escape(0x61) == Ok("^^61")
  assert long_control_escape(0x00) == Ok("^^00")
  assert long_control_escape(0x09) == Ok("^^09")
  assert long_control_escape(0x0A) == Ok("^^0a")
  assert long_control_escape(0x0F) == Ok("^^0f")
  assert long_control_escape(0x90) == Ok("^^90")
  assert long_control_escape(0x99) == Ok("^^99")
  assert long_control_escape(0x9A) == Ok("^^9a")
  assert long_control_escape(0x9F) == Ok("^^9f")
  assert long_control_escape(0xA0) == Ok("^^a0")
  assert long_control_escape(0xA9) == Ok("^^a9")
  assert long_control_escape(0xAA) == Ok("^^aa")
  assert long_control_escape(0xAF) == Ok("^^af")
  assert long_control_escape(0xF0) == Ok("^^f0")
  assert long_control_escape(0xF9) == Ok("^^f9")
  assert long_control_escape(0xFA) == Ok("^^fa")
  assert long_control_escape(0xFF) == Ok("^^ff")
}

pub fn parse_control_escape_test() {
  assert latex.parse_control_escape("A") == "A"
  assert latex.parse_control_escape("^^") ==""

  assert latex.parse_control_escape("^^!") == "a"
  assert latex.parse_control_escape("^^a") == "!"
  assert latex.parse_control_escape("^^M") == "\r"
  assert latex.parse_control_escape("^^?") == "\u{7F}"
  assert latex.parse_control_escape("^^@") == "\u{00}"
  assert latex.parse_control_escape("^^^") == "\u{1E}"
  assert latex.parse_control_escape("^^\r") == "M"
  assert latex.parse_control_escape("^^\u{7F}") == "?"
  assert latex.parse_control_escape("^^\u{00}") == "@"
  assert latex.parse_control_escape("^^\u{1E}") == "^"

  assert latex.parse_control_escape("^^61") == "a"
  assert latex.parse_control_escape("^^00") == "\u{00}"
  assert latex.parse_control_escape("^^09") == "\u{09}"
  assert latex.parse_control_escape("^^0a") == "\u{0A}"
  assert latex.parse_control_escape("^^0f") == "\u{0F}"
  assert latex.parse_control_escape("^^90") == "\u{90}"
  assert latex.parse_control_escape("^^99") == "\u{99}"
  assert latex.parse_control_escape("^^9a") == "\u{9A}"
  assert latex.parse_control_escape("^^9f") == "\u{9F}"
  assert latex.parse_control_escape("^^a0") == "\u{A0}"
  assert latex.parse_control_escape("^^a9") == "\u{A9}"
  assert latex.parse_control_escape("^^aa") == "\u{AA}"
  assert latex.parse_control_escape("^^af") == "\u{AF}"
  assert latex.parse_control_escape("^^f0") == "\u{F0}"
  assert latex.parse_control_escape("^^f9") == "\u{F9}"
  assert latex.parse_control_escape("^^fa") == "\u{FA}"
  assert latex.parse_control_escape("^^ff") == "\u{FF}"

  assert latex.parse_control_escape("^^5c^^27^^7b^^65^^7d") == "\\'{e}"
  assert latex.parse_control_escape("^^5c^^g^^;^^%^^=") == "\\'{e}"
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
  assert latex.text_to_grapheme("\\AE") == Ok("Æ")
  assert latex.text_to_grapheme("\\ae") == Ok("æ")
  assert latex.text_to_grapheme("\\i") == Ok("ı")
  assert latex.text_to_grapheme("\\j") == Ok("ȷ")
}

pub fn math_to_grapheme_test() {
  assert latex.math_to_grapheme("'") == Ok("′")
  assert latex.math_to_grapheme("\\>") == Ok("\u{205F}")
  assert latex.math_to_grapheme("\\not") == Ok("\u{0338}")
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
    use #(math_type, _) <- result.try(latex.unimath(command))
    Ok(math_type)
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
