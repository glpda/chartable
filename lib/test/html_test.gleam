import birdie
import chartable/html
import chartable/internal
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

pub fn entities_test() {
  let assert Ok(entity_table) = html.make_entity_table()

  assert string.utf_codepoint(0x22C6)
    |> result.try(dict.get(entity_table.from_codepoint, _))
    |> result.map(list.sort(_, string.compare))
    == Ok(["Star", "sstarf"])

  assert dict.get(entity_table.to_codepoints, "Star")
    == Ok(string.to_utf_codepoints("\u{22C6}"))

  internal.assert_table_consistency(
    entity_table.from_codepoint,
    entity_table.to_codepoints,
  )

  internal.from_codepoint_table_to_string(entity_table.from_codepoint)
  |> birdie.snap(title: "HTML entities from codepoints")
}

pub fn entity_to_codepoints_test() {
  let assert Ok(entity_table) = html.make_entity_table()
  // Ok(['⋆']):
  let star = Ok(string.to_utf_codepoints("\u{22C6}"))

  assert html.entity_to_codepoints("&Star;", entity_table) == star

  assert html.entity_to_codepoints("&#x22C6;", entity_table) == star

  assert html.entity_to_codepoints("&#8902;", entity_table) == star

  assert html.entity_to_codepoints("&Staaar;", entity_table) == Error(Nil)

  assert html.entity_to_codepoints("Star", entity_table) == Error(Nil)
}

pub fn entity_to_string_test() {
  let assert Ok(entity_table) = html.make_entity_table()

  assert html.entity_to_string("&Star;", entity_table) == Ok("⋆")

  assert html.entity_to_string("&#x22C6;", entity_table) == Ok("\u{22C6}")

  assert html.entity_to_string("&#8902;", entity_table) == Ok("\u{22C6}")

  assert html.entity_to_string("&Staaar;", entity_table) == Error(Nil)

  assert html.entity_to_string("Star", entity_table) == Error(Nil)
}

pub fn entity_from_codepoint_test() {
  let assert Ok(entity_table) = html.make_entity_table()
  // '⋆':
  let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)
  // '⭐':
  let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)

  assert html.entities_from_codepoint(star_symbol, entity_table)
    |> list.sort(string.compare)
    == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]

  assert html.entities_from_codepoint(star_emoji, entity_table)
    |> list.sort(string.compare)
    == ["&#11088;", "&#x2B50;"]
}
