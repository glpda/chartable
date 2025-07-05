//// Converts between Unicode code points and html
//// [entities / character references](https://html.spec.whatwg.org/multipage/named-characters.html)

import chartable/html/entities
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// Maps code points to html named character references.
///
pub type FromCodepoint =
  Dict(UtfCodepoint, List(String))

/// Maps html named character references to code points.
///
pub type ToCodepoints =
  Dict(String, List(UtfCodepoint))

/// Maps code points to named character references and the other way around.
pub type Table {
  Table(from_codepoint: FromCodepoint, to_codepoints: ToCodepoints)
}

/// Makes entity table. Requires parsing `entities.json`:
/// for better performance, call only once and keep the dictionary.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(entity_table) = html.make_entity_table()
///
/// assert Ok(["sstarf", "Star"])
///   == string.utf_codepoint(0x22C6)
///   |> result.try(dict.get(entity_table.from_codepoint, _))
///
/// assert Ok(string.to_utf_codepoints("\u{22C6}"))  // Ok(['⋆'])
///   == dict.get(entity_table.to_codepoints, "Star")
/// ```
///
pub fn make_entity_table() {
  let codepoints_decoder = decode.string |> decode.map(string.to_utf_codepoints)
  let decoder = decode.dict(decode.string, codepoints_decoder)

  use to_codepoints <- result.map(json.parse(
    from: entities.json,
    using: decoder,
  ))
  let from_codepoint = make_reverse_table(to_codepoints)
  Table(from_codepoint:, to_codepoints:)
}

fn make_reverse_table(input) {
  use reverse, entity, codepoints <- dict.fold(over: input, from: dict.new())
  case codepoints {
    [codepoint] ->
      dict.upsert(codepoint, in: reverse, with: fn(option) {
        case option {
          None -> [entity]
          Some(list) -> [entity, ..list]
        }
      })
    _ -> reverse
  }
}
