import birdie
import chartable/internal/notation_table.{type NotationTable}
import chartable/internal/typst_codegen
import chartable/typst
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn assert_codegen_match_table(table: NotationTable, prefix: String) -> Nil {
  dict.each(table.codepoint_to_notations, fn(codepoint, notations) {
    assert typst.notations_from_codepoint(codepoint)
      |> list.filter_map(fn(notation) {
        string.split_once(notation, on: prefix)
        |> result.map(fn(pair) { pair.1 })
      })
      == list.sort(notations, string.compare)
  })

  dict.each(table.notation_to_codepoints, fn(notation, codepoints) {
    assert typst.notation_to_codepoints(prefix <> notation) == Ok(codepoints)
  })
}

pub fn symbol_codegen_test() {
  let assert Ok(sym) = simplifile.read("data/typst/sym.txt")
  let assert Ok(table) = typst_codegen.parse_codex(sym)

  notation_table.assert_consistency(table)

  assert_codegen_match_table(table, "#sym.")

  notation_table.to_string(table)
  |> birdie.snap(title: "Typst symbol notations from codepoints")
}

pub fn emoji_codegen_test() {
  let assert Ok(emoji) = simplifile.read("data/typst/emoji.txt")
  let assert Ok(table) = typst_codegen.parse_codex(emoji)

  notation_table.assert_consistency(table)

  assert_codegen_match_table(table, "#emoji.")

  notation_table.to_string(table)
  |> birdie.snap(title: "Typst emoji notations from codepoints")
}

pub fn symbols_from_codepoint_test() {
  assert string.utf_codepoint(0x22C6)
    |> result.try(typst.symbols_from_codepoint)
    == Ok(["star.op"])

  assert string.utf_codepoint(0x0024)
    |> result.try(typst.symbols_from_codepoint)
    == Ok(["dollar", "pataca", "peso"])
}

pub fn symbol_to_codepoints_test() {
  assert typst.symbol_to_codepoints("star.op")
    == Ok(string.to_utf_codepoints("\u{22C6}"))

  assert typst.symbol_to_codepoints("dollar")
    == Ok(string.to_utf_codepoints("$"))
}

pub fn emoji_from_codepoint_test() {
  assert string.utf_codepoint(0x2B50)
    |> result.try(typst.emojis_from_codepoint)
    == Ok(["star"])

  assert string.utf_codepoint(0x1F31F)
    |> result.try(typst.emojis_from_codepoint)
    == Ok(["star.glow"])
}

pub fn emoji_to_codepoints_test() {
  assert typst.emoji_to_codepoints("star") == Ok(string.to_utf_codepoints("⭐"))

  assert typst.emoji_to_codepoints("star.glow")
    == Ok(string.to_utf_codepoints("\u{1F31F}"))
}

pub fn markup_shorthand_to_codepoint_test() {
  let en_dash = string.utf_codepoint(0x2013)

  assert typst.markup_shorthand_to_codepoint("--") == en_dash
}

pub fn markup_shorthand_from_codepoint_test() {
  let assert Ok(en_dash) = string.utf_codepoint(0x2013)

  assert typst.markup_shorthand_from_codepoint(en_dash) == Ok("--")
}

pub fn math_shorthand_to_codepoint_test() {
  let arrow = string.utf_codepoint(0x2192)

  assert typst.math_shorthand_to_codepoint("->") == arrow
}

pub fn math_shorthand_from_codepoint_test() {
  let assert Ok(arrow) = string.utf_codepoint(0x2192)

  assert typst.math_shorthand_from_codepoint(arrow) == Ok("->")
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
    Ok(#(codepoint, notations))
  })
  |> dict.from_list()
  |> notation_table.complement_codepoint_to_notations()
}

pub fn math_alphanum_from_codepoint_test() {
  assert string.utf_codepoint(0x0043)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["upright(C)"])

  assert string.utf_codepoint(0x1D436)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["C"])

  assert string.utf_codepoint(0x1D53A)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Error(Nil)

  assert string.utf_codepoint(0x2102)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["bb(C)"])

  assert string.utf_codepoint(0x1D6AA)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["bold(Gamma)"])

  assert string.utf_codepoint(0x1D6C4)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["bold(upright(gamma))"])

  assert string.utf_codepoint(0x1D4F1)
    |> result.try(typst.math_alphanum_from_codepoint)
    == Ok(["bold(cal(h))"])

  make_math_alphanum_notation_table()
  |> notation_table.to_string()
  |> birdie.snap(title: "Typst math alphanumeric notations from codepoints")
}

pub fn notations_from_codepoint_test() {
  assert string.utf_codepoint(0x1F31F)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["#emoji.star.glow"])

  assert string.utf_codepoint(0x22C6)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["#sym.star.op"])

  assert string.utf_codepoint(0x2013)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["#sym.dash.en", "--"])

  assert string.utf_codepoint(0x2192)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["#sym.arrow.r", "$ -> $"])

  assert string.utf_codepoint(0x0393)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["#sym.Gamma", "$ Gamma $"])

  assert string.utf_codepoint(0x1D6AA)
    |> result.map(typst.notations_from_codepoint)
    == Ok(["$ bold(Gamma) $"])
}

pub fn notation_to_codepoints_test() {
  assert typst.notation_to_codepoints("#sym.star.op")
    == Ok(string.to_utf_codepoints("\u{22C6}"))

  assert typst.notation_to_codepoints("#emoji.star")
    == Ok(string.to_utf_codepoints("\u{2B50}"))

  assert typst.notation_to_codepoints("emoji.star") == Error(Nil)

  assert typst.notation_to_codepoints("#emoji.staaar") == Error(Nil)
}

pub fn notation_to_string_test() {
  assert typst.notation_to_string("#sym.star.op") == Ok("\u{22C6}")

  assert typst.notation_to_string("#emoji.star") == Ok("\u{2B50}")

  assert typst.notation_to_string("emoji.star") == Error(Nil)

  assert typst.notation_to_string("#emoji.staaar") == Error(Nil)
}
