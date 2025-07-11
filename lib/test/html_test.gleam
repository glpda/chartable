import birdie
import chartable/html
import chartable/internal
import gleam/dict
import gleam/result
import gleam/string

pub fn entities_test() {
  let assert Ok(entity_table) = html.make_entity_table()

  assert Ok(["sstarf", "Star"])
    == string.utf_codepoint(0x22C6)
    |> result.try(dict.get(entity_table.from_codepoint, _))

  assert Ok(string.to_utf_codepoints("\u{22C6}"))
    == dict.get(entity_table.to_codepoints, "Star")

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

  assert star == html.entity_to_codepoints("&Star;", entity_table)

  assert star == html.entity_to_codepoints("&#x22C6;", entity_table)

  assert star == html.entity_to_codepoints("&#8902;", entity_table)

  assert Error(Nil) == html.entity_to_codepoints("&Staaar;", entity_table)

  assert Error(Nil) == html.entity_to_codepoints("Star", entity_table)
}

pub fn entity_to_string_test() {
  let assert Ok(entity_table) = html.make_entity_table()

  assert Ok("⋆") == html.entity_to_string("&Star;", entity_table)

  assert Ok("\u{22C6}") == html.entity_to_string("&#x22C6;", entity_table)

  assert Ok("\u{22C6}") == html.entity_to_string("&#8902;", entity_table)

  assert Error(Nil) == html.entity_to_string("&Staaar;", entity_table)

  assert Error(Nil) == html.entity_to_string("Star", entity_table)
}

pub fn entity_from_codepoint_test() {
  let assert Ok(entity_table) = html.make_entity_table()
  // '⋆':
  let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)
  // '⭐':
  let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)

  assert ["&#x22C6;", "&#8902;", "&sstarf;", "&Star;"]
    == html.entities_from_codepoint(star_symbol, entity_table)

  assert ["&#x2B50;", "&#11088;"]
    == html.entities_from_codepoint(star_emoji, entity_table)
}
