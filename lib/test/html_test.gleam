import birdie
import chartable/html
import chartable/internal
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

/// Asserts table consistency (`from_codepoint` match `to_codepoints`),
/// ignores html entities mapping to multiple codepoints wich are not
/// included in `from_codepoint` table.
fn table_equality(table: html.Table) {
  dict.each(table.to_codepoints, fn(entity, codepoints) {
    case codepoints {
      [codepoint] -> {
        assert dict.get(table.from_codepoint, codepoint)
          |> result.unwrap(or: [])
          |> list.contains(entity)
      }
      _ -> Nil
    }
  })
  dict.each(table.from_codepoint, fn(codepoint, entities) {
    assert list.all(entities, fn(entity) {
      dict.get(table.to_codepoints, entity) == Ok([codepoint])
    })
  })
}

pub fn entities_test() {
  let assert Ok(entity_table) = html.make_entity_table()

  assert Ok(["sstarf", "Star"])
    == string.utf_codepoint(0x22C6)
    |> result.try(dict.get(entity_table.from_codepoint, _))

  assert Ok(string.to_utf_codepoints("\u{22C6}"))
    == dict.get(entity_table.to_codepoints, "Star")

  table_equality(entity_table)

  internal.from_codepoint_table_to_string(entity_table.from_codepoint)
  |> birdie.snap(title: "HTML entities from codepoints")
}
