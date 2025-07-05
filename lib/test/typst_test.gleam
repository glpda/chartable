import birdie
import chartable/internal
import chartable/typst
import gleam/dict
import gleam/result
import gleam/string

pub fn symtable_test() {
  let assert Ok(symtable) = typst.make_symtable()

  assert Ok(["star.op"])
    == string.utf_codepoint(0x22C6)
    |> result.try(dict.get(symtable.from_codepoint, _))

  assert Ok(string.to_utf_codepoints("\u{22C6}"))
    == dict.get(symtable.to_codepoints, "star.op")

  internal.assert_table_equality(
    symtable.from_codepoint,
    symtable.to_codepoints,
  )

  internal.from_codepoint_table_to_string(symtable.from_codepoint)
  |> birdie.snap(title: "Typst symbol notation from codepoints")
}

pub fn emojitable_test() {
  let assert Ok(emojitable) = typst.make_emojitable()

  assert Ok(["star.glow"])
    == string.utf_codepoint(0x1F31F)
    |> result.try(dict.get(emojitable.from_codepoint, _))

  assert Ok(string.to_utf_codepoints("\u{1F31F}"))
    == dict.get(emojitable.to_codepoints, "star.glow")

  internal.assert_table_equality(
    emojitable.from_codepoint,
    emojitable.to_codepoints,
  )

  internal.from_codepoint_table_to_string(emojitable.from_codepoint)
  |> birdie.snap(title: "Typst emoji notation from codepoints")
}

pub fn markup_shorthand_to_codepoint_test() {
  let en_dash = string.utf_codepoint(0x2013)

  assert en_dash == typst.markup_shorthand_to_codepoint("--")
}

pub fn markup_shorthand_from_codepoint_test() {
  let assert Ok(en_dash) = string.utf_codepoint(0x2013)

  assert Ok("--") == typst.markup_shorthand_from_codepoint(en_dash)
}

pub fn math_shorthand_to_codepoint_test() {
  let arrow = string.utf_codepoint(0x2192)

  assert arrow == typst.math_shorthand_to_codepoint("->")
}

pub fn math_shorthand_from_codepoint_test() {
  let assert Ok(arrow) = string.utf_codepoint(0x2192)

  assert Ok("->") == typst.math_shorthand_from_codepoint(arrow)
}
