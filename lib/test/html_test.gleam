import birdie
import chartable/html
import chartable/internal/html_codegen
import chartable/internal/notation_table.{type NotationTable}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn assert_codegen_match_table(table: NotationTable) -> Nil {
  dict.each(table.grapheme_to_notations, fn(grapheme, notations) {
    assert html.named_character_references(grapheme)
      == list.sort(notations, string.compare)
      |> list.map(fn(notation) { "&" <> notation <> ";" })
  })

  dict.each(table.notation_to_grapheme, fn(notation, grapheme) {
    assert html.character_reference_to_grapheme("&" <> notation <> ";")
      == Ok(grapheme)
  })
}

pub fn entity_codegen_test() {
  let assert Ok(json) = simplifile.read("data/html/entities.json")
  let assert Ok(table) = html_codegen.parse_entities_json(json)

  notation_table.assert_consistency(table)

  assert_codegen_match_table(table)

  notation_table.to_string(table)
  |> birdie.snap(title: "HTML entities from codepoints")
}

pub fn named_character_references_test() {
  assert html.named_character_references("⋆")
    == ["&Star;", "&sstarf;"]

  assert html.named_character_references("⭐") == []
}

pub fn decimal_character_reference_test() {
  assert string.utf_codepoint(8902)
    |> result.map(html.decimal_character_reference)
    == Ok("&#8902;")

  assert string.utf_codepoint(11_088)
    |> result.map(html.decimal_character_reference)
    == Ok("&#11088;")
}

pub fn hexadecimal_character_reference_test() {
  assert string.utf_codepoint(0x22C6)
    |> result.map(html.hexadecimal_character_reference)
    == Ok("&#x22C6;")

  assert string.utf_codepoint(0x2B50)
    |> result.map(html.hexadecimal_character_reference)
    == Ok("&#x2B50;")
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
