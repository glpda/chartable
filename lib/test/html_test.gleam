import chartable/html
import gleam/list
import gleam/result
import gleam/string

pub fn named_character_references_test() {
  assert html.named_character_references("⋆") == ["&Star;", "&sstarf;"]
  assert html.named_character_references("⭐") == []
}

pub fn decimal_character_reference_test() {
  let decimal_character_reference = fn(cp) {
    result.map(string.utf_codepoint(cp), html.decimal_character_reference)
  }
  assert decimal_character_reference(8902) == Ok("&#8902;")
  assert decimal_character_reference(11_088) == Ok("&#11088;")
}

pub fn hexadecimal_character_reference_test() {
  let hexadecimal_character_reference = fn(cp) {
    result.map(string.utf_codepoint(cp), html.hexadecimal_character_reference)
  }
  assert hexadecimal_character_reference(0x22C6) == Ok("&#x22C6;")
  assert hexadecimal_character_reference(0x2B50) == Ok("&#x2B50;")
}

pub fn character_references_from_codepoint_test() {
  let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)
  let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)

  assert html.character_references_from_codepoint(star_symbol)
    |> list.sort(string.compare)
    == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]
  assert html.character_references_from_codepoint(star_emoji)
    |> list.sort(string.compare)
    == ["&#11088;", "&#x2B50;"]
}

pub fn character_references_from_grapheme_test() {
  assert html.character_references_from_grapheme("⋆")
    |> list.sort(string.compare)
    == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]
  assert html.character_references_from_grapheme("⭐")
    |> list.sort(string.compare)
    == ["&#11088;", "&#x2B50;"]
}

pub fn character_reference_to_grapheme_test() {
  assert html.character_reference_to_grapheme("&Star;") == Ok("⋆")
  assert html.character_reference_to_grapheme("&#x22C6;") == Ok("\u{22C6}")
  assert html.character_reference_to_grapheme("&#8902;") == Ok("\u{22C6}")
  assert html.character_reference_to_grapheme("&Staaar;") == Error(Nil)
  assert html.character_reference_to_grapheme("Star") == Error(Nil)
}
