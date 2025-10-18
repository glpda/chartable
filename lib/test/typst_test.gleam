import birdie
import chartable/typst
import codegen/notation_table
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

pub fn symbols_from_grapheme_test() {
  assert typst.symbols_from_grapheme("\u{26A7}") == ["#sym.gender.trans"]
  assert typst.symbols_from_grapheme("\u{26A7}\u{FE0F}") == []
  assert typst.symbols_from_grapheme("\u{26A7}\u{FE0E}")
    == ["#sym.gender.trans"]
  assert typst.symbols_from_grapheme("⋆") == ["#sym.star.op"]
  assert typst.symbols_from_grapheme("$")
    == ["#sym.dollar", "#sym.pataca", "#sym.peso"]
}

pub fn symbols_from_codepoint_test() {
  let symbols_from_int = fn(cp) {
    result.map(string.utf_codepoint(cp), typst.symbols_from_codepoint)
  }
  assert symbols_from_int(0x26A7) == Ok(["#sym.gender.trans"])
  assert symbols_from_int(0x22C6) == Ok(["#sym.star.op"])
  assert symbols_from_int(0x0024)
    == Ok(["#sym.dollar", "#sym.pataca", "#sym.peso"])
}

pub fn emojis_from_grapheme_test() {
  assert typst.emojis_from_grapheme("\u{26A7}") == ["#emoji.transgender"]
  assert typst.emojis_from_grapheme("\u{26A7}\u{FE0E}") == []
  assert typst.emojis_from_grapheme("\u{26A7}\u{FE0F}")
    == ["#emoji.transgender"]
  assert typst.emojis_from_grapheme("⭐") == ["#emoji.star"]
  assert typst.emojis_from_grapheme("🌟") == ["#emoji.star.glow"]
}

pub fn emojis_from_codepoint_test() {
  let emojis_from_int = fn(cp) {
    result.map(string.utf_codepoint(cp), typst.emojis_from_codepoint)
  }
  assert emojis_from_int(0x2B50) == Ok(["#emoji.star"])
  assert emojis_from_int(0x1F31F) == Ok(["#emoji.star.glow"])
}

pub fn markup_shorthand_to_codepoint_test() {
  assert typst.markup_shorthand_to_codepoint("--")
    == string.utf_codepoint(0x2013)
}

pub fn markup_shorthand_to_grapheme_test() {
  assert typst.markup_shorthand_to_grapheme("--") == Ok("–")
}

pub fn markup_shorthand_from_codepoint_test() {
  let assert Ok(en_dash) = string.utf_codepoint(0x2013)
  assert typst.markup_shorthand_from_codepoint(en_dash) == Ok("--")
}

pub fn markup_shorthand_from_grapheme_test() {
  assert typst.markup_shorthand_from_grapheme("–") == Ok("--")
}

pub fn math_shorthand_to_codepoint_test() {
  assert typst.math_shorthand_to_codepoint("->") == string.utf_codepoint(0x2192)
}

pub fn math_shorthand_to_grapheme_test() {
  assert typst.math_shorthand_to_grapheme("->") == Ok("→")
}

pub fn math_shorthand_from_codepoint_test() {
  let assert Ok(arrow) = string.utf_codepoint(0x2192)
  assert typst.math_shorthand_from_codepoint(arrow) == Ok("->")
}

pub fn math_shorthand_from_grapheme_test() {
  assert typst.math_shorthand_from_grapheme("→") == Ok("->")
}

fn make_math_alphanum_notation_table() {
  let ascii_digits = list.range(from: 0x0030, to: 0x0039)
  let uppercase_latin_letters = list.range(from: 0x0041, to: 0x005A)
  let lowercase_latin_letters = list.range(from: 0x0061, to: 0x007A)
  let dotless_latin_letters = [0x0131, 0x0237]
  let uppercase_greek_letters = list.range(from: 0x0391, to: 0x03A9)
  let lowercase_greek_letters = list.range(from: 0x03B1, to: 0x03C9)
  let greek_symbols = [
    0x03D0, 0x03D1, 0x03D5, 0x03D6, 0x03DC, 0x03DD, 0x03F0, 0x03F1, 0x03F4,
    0x03F5,
  ]
  let letterlike_symbols = [
    0x2102, 0x210A, 0x210B, 0x210C, 0x210D, 0x210E, 0x2110, 0x2111, 0x2112,
    0x2113, 0x2115, 0x2118, 0x2119, 0x211A, 0x211B, 0x211C, 0x211D, 0x2124,
    0x2128, 0x212C, 0x212D, 0x212F, 0x2130, 0x2131, 0x2133, 0x2134, 0x2135,
    0x2136, 0x2137, 0x2138, 0x213C, 0x213D, 0x213E, 0x213F, 0x2140, 0x2145,
    0x2146, 0x2147, 0x2148, 0x2149, 0x2202, 0x2207,
  ]
  let math_alphanum_symbols = list.range(from: 0x1D400, to: 0x1D7FF)
  let codepoints =
    ascii_digits
    |> list.append(uppercase_latin_letters)
    |> list.append(lowercase_latin_letters)
    |> list.append(dotless_latin_letters)
    |> list.append(uppercase_greek_letters)
    |> list.append(lowercase_greek_letters)
    |> list.append(greek_symbols)
    |> list.append(letterlike_symbols)
    |> list.append(math_alphanum_symbols)
  list.filter_map(codepoints, fn(number) {
    use codepoint <- result.try(string.utf_codepoint(number))
    let notations =
      result.unwrap(typst.math_alphanum_from_codepoint(codepoint), or: [])
    let grapheme = string.from_utf_codepoints([codepoint])
    Ok(#(grapheme, notations))
  })
  |> dict.from_list()
  |> notation_table.complement_grapheme_to_notations()
}

pub fn math_alphanum_from_codepoint_test() {
  let math_alphanum_from_int = fn(cp) {
    result.try(string.utf_codepoint(cp), typst.math_alphanum_from_codepoint)
  }
  assert math_alphanum_from_int(0x0043) == Ok(["upright(C)"])
  assert math_alphanum_from_int(0x1D436) == Ok(["C"])
  assert math_alphanum_from_int(0x1D53A) == Error(Nil)
  assert math_alphanum_from_int(0x2102) == Ok(["bb(C)"])
  assert math_alphanum_from_int(0x1D6AA) == Ok(["bold(Gamma)"])
  assert math_alphanum_from_int(0x1D6C4) == Ok(["bold(upright(gamma))"])
  assert math_alphanum_from_int(0x1D4F1) == Ok(["bold(cal(h))"])

  make_math_alphanum_notation_table()
  |> notation_table.to_string()
  |> birdie.snap(title: "Typst math alphanumeric notations from codepoints")
}

pub fn notations_from_grapheme_test() {
  assert typst.notations_from_grapheme("\u{1F31F}") == ["#emoji.star.glow"]
  assert typst.notations_from_grapheme("\u{22C6}") == ["#sym.star.op"]
  assert typst.notations_from_grapheme("\u{2013}") == ["#sym.dash.en", "--"]
  assert typst.notations_from_grapheme("\u{2192}") == ["#sym.arrow.r", "$ -> $"]
  assert typst.notations_from_grapheme("\u{26A7}")
    == ["#sym.gender.trans", "#emoji.transgender"]
  assert typst.notations_from_grapheme("\u{0393}")
    == ["#sym.Gamma", "$ Gamma $"]
  assert typst.notations_from_grapheme("\u{1D6AA}") == ["$ bold(Gamma) $"]
}

pub fn notation_to_grapheme_test() {
  assert typst.notation_to_grapheme("#sym.star.op") == Ok("\u{22C6}")
  assert typst.notation_to_grapheme("#emoji.star") == Ok("\u{2B50}\u{FE0F}")
  assert typst.notation_to_grapheme("emoji.star") == Error(Nil)
  assert typst.notation_to_grapheme("#emoji.staaar") == Error(Nil)
}
