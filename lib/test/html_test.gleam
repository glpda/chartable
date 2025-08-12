import birdie
import chartable/html
import chartable/internal/html_codegen
import chartable/internal/notation_table.{type NotationTable}
import gleam/dict
import gleam/list
import gleam/string
import simplifile

fn assert_codegen_match_table(table: NotationTable) -> Nil {
  dict.each(table.codepoint_to_notations, fn(codepoint, notations) {
    assert html.entities_from_codepoint(codepoint)
      |> list.filter(fn(notation) { !string.starts_with(notation, "&#") })
      == list.sort(notations, string.compare)
      |> list.map(fn(notation) { "&" <> notation <> ";" })
  })

  dict.each(table.notation_to_codepoints, fn(notation, codepoints) {
    assert html.entity_to_codepoints("&" <> notation <> ";") == Ok(codepoints)
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

pub fn entity_to_codepoints_test() {
  // Ok(['⋆']):
  let star = Ok(string.to_utf_codepoints("\u{22C6}"))

  assert html.entity_to_codepoints("&Star;") == star

  assert html.entity_to_codepoints("&#x22C6;") == star

  assert html.entity_to_codepoints("&#8902;") == star

  assert html.entity_to_codepoints("&Staaar;") == Error(Nil)

  assert html.entity_to_codepoints("Star") == Error(Nil)
}

pub fn entity_to_string_test() {
  assert html.entity_to_string("&Star;") == Ok("⋆")

  assert html.entity_to_string("&#x22C6;") == Ok("\u{22C6}")

  assert html.entity_to_string("&#8902;") == Ok("\u{22C6}")

  assert html.entity_to_string("&Staaar;") == Error(Nil)

  assert html.entity_to_string("Star") == Error(Nil)
}

pub fn entity_from_codepoint_test() {
  // '⋆':
  let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)
  // '⭐':
  let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)

  assert html.entities_from_codepoint(star_symbol)
    |> list.sort(string.compare)
    == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]

  assert html.entities_from_codepoint(star_emoji)
    |> list.sort(string.compare)
    == ["&#11088;", "&#x2B50;"]
}
