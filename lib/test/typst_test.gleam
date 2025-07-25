import birdie
import chartable/internal
import chartable/typst
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

pub fn symtable_test() {
  let assert Ok(symtable) = typst.make_symtable()

  assert string.utf_codepoint(0x22C6)
    |> result.try(dict.get(symtable.from_codepoint, _))
    == Ok(["star.op"])

  assert dict.get(symtable.to_codepoints, "star.op")
    == Ok(string.to_utf_codepoints("\u{22C6}"))

  internal.assert_table_consistency(
    symtable.from_codepoint,
    symtable.to_codepoints,
  )

  internal.from_codepoint_table_to_string(symtable.from_codepoint)
  |> birdie.snap(title: "Typst symbol notations from codepoints")
}

pub fn emojitable_test() {
  let assert Ok(emojitable) = typst.make_emojitable()

  assert string.utf_codepoint(0x1F31F)
    |> result.try(dict.get(emojitable.from_codepoint, _))
    == Ok(["star.glow"])

  assert dict.get(emojitable.to_codepoints, "star.glow")
    == Ok(string.to_utf_codepoints("\u{1F31F}"))

  internal.assert_table_consistency(
    emojitable.from_codepoint,
    emojitable.to_codepoints,
  )

  internal.from_codepoint_table_to_string(emojitable.from_codepoint)
  |> birdie.snap(title: "Typst emoji notations from codepoints")
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

fn make_math_alphanum_from_codepoint_dict(symtable) {
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
      result.unwrap(
        typst.math_alphanum_from_codepoint(codepoint, symtable),
        or: [],
      )
    Ok(#(codepoint, notations))
  })
  |> dict.from_list()
}

pub fn math_alphanum_from_codepoint_test() {
  let assert Ok(symtable) = typst.make_symtable()

  assert string.utf_codepoint(0x0043)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["upright(C)"])

  assert string.utf_codepoint(0x1D436)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["C"])

  assert string.utf_codepoint(0x1D53A)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Error(Nil)

  assert string.utf_codepoint(0x2102)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["bb(C)"])

  assert string.utf_codepoint(0x1D6AA)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["bold(Gamma)"])

  assert string.utf_codepoint(0x1D6C4)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["bold(upright(gamma))"])

  assert string.utf_codepoint(0x1D4F1)
    |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
    == Ok(["bold(cal(h))"])

  make_math_alphanum_from_codepoint_dict(symtable)
  |> internal.from_codepoint_table_to_string()
  |> birdie.snap(title: "Typst math alphanumeric notations from codepoints")
}

pub fn notations_from_codepoint_test() {
  let assert Ok(tables) = typst.make_tables()

  assert string.utf_codepoint(0x1F31F)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["#emoji.star.glow"])

  assert string.utf_codepoint(0x22C6)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["#sym.star.op"])

  assert string.utf_codepoint(0x2013)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["#sym.dash.en", "--"])

  assert string.utf_codepoint(0x2192)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["#sym.arrow.r", "$ -> $"])

  assert string.utf_codepoint(0x0393)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["#sym.Gamma", "$ Gamma $"])

  assert string.utf_codepoint(0x1D6AA)
    |> result.map(typst.notations_from_codepoint(_, tables))
    == Ok(["$ bold(Gamma) $"])
}

pub fn notation_to_codepoints_test() {
  let assert Ok(tables) = typst.make_tables()

  assert typst.notation_to_codepoints("#sym.star.op", tables)
    == Ok(string.to_utf_codepoints("\u{22C6}"))

  assert typst.notation_to_codepoints("#emoji.star", tables)
    == Ok(string.to_utf_codepoints("\u{2B50}"))

  assert typst.notation_to_codepoints("emoji.star", tables) == Error(Nil)

  assert typst.notation_to_codepoints("#emoji.staaar", tables) == Error(Nil)
}

pub fn notation_to_string_test() {
  let assert Ok(tables) = typst.make_tables()

  assert typst.notation_to_string("#sym.star.op", tables) == Ok("\u{22C6}")

  assert typst.notation_to_string("#emoji.star", tables) == Ok("\u{2B50}")

  assert typst.notation_to_string("emoji.star", tables) == Error(Nil)

  assert typst.notation_to_string("#emoji.staaar", tables) == Error(Nil)
}
