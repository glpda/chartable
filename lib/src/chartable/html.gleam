//// Converts between Unicode code points and html
//// [entities / character references](https://html.spec.whatwg.org/multipage/named-characters.html)

import chartable/html/entities
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// Maps code points to html named character references.
///
/// Prefer [`entity_from_codepoint`](#entities_from_codepoint)
/// over direclty working with table dictionaries.
pub type FromCodepoint =
  Dict(UtfCodepoint, List(String))

/// Maps html named character references to code points.
///
/// Prefer [`entity_to_codepoints`](#entities_to_codepoints)
/// over direclty working with table dictionaries.
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

/// Converts an html character reference `String` to a `List` of `UtfCodepoint`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(entity_table) = html.make_entity_table()
/// let star = Ok(string.to_utf_codepoints("\u{22C6}"))  // Ok(['⋆'])
///
/// assert star == html.entity_to_codepoints("&Star;", entity_table)
///
/// assert star == html.entity_to_codepoints("&#x22C6;", entity_table)
///
/// assert star == html.entity_to_codepoints("&#8902;", entity_table)
///
/// assert Error(Nil) == html.entity_to_codepoints("&Staaar;", entity_table)
///
/// assert Error(Nil) == html.entity_to_codepoints("Star", entity_table)
/// ```
///
pub fn entity_to_codepoints(
  entity: String,
  table table: Table,
) -> Result(List(UtfCodepoint), Nil) {
  use inner <- result.try(case entity, string.ends_with(entity, ";") {
    "&" <> entity, True -> Ok(string.drop_end(from: entity, up_to: 1))
    _, _ -> Error(Nil)
  })
  use <- result.lazy_or(dict.get(table.to_codepoints, inner))
  numeric_entity_to_codepoints(inner) |> result.map(list.wrap)
}

fn numeric_entity_to_codepoints(entity: String) -> Result(UtfCodepoint, Nil) {
  case entity {
    "#x" <> hex | "#X" <> hex -> int.base_parse(hex, 16)
    "#" <> dec -> int.parse(dec)
    _ -> Error(Nil)
  }
  |> result.try(string.utf_codepoint)
}

/// Converts an html character reference `String` to the escaped string.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(entity_table) = html.make_entity_table()
///
/// assert Ok("⋆") == html.entity_to_string("&Star;", entity_table)
///
/// assert Ok("\u{22C6}") == html.entity_to_string("&#x22C6;", entity_table)
///
/// assert Ok("\u{22C6}") == html.entity_to_string("&#8902;", entity_table)
///
/// assert Error(Nil) == html.entity_to_string("&Staaar;", entity_table)
///
/// assert Error(Nil) == html.entity_to_string("Star", entity_table)
/// ```
///
pub fn entity_to_string(
  entity: String,
  table table: Table,
) -> Result(String, Nil) {
  entity_to_codepoints(entity, table)
  |> result.map(string.from_utf_codepoints)
}

/// Converts a `UtfCodepoint` to a `List` of html character references `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(entity_table) = html.make_entity_table()
/// let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)  // '⋆'
/// let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)   // '⭐'
///
/// assert ["&#x22C6;", "&#8902;", "&sstarf;", "&Star;"]
///   == html.entities_from_codepoint(star_symbol, entity_table)
///
/// assert ["&#x2B50;", "&#11088;"]
///   == html.entities_from_codepoint(star_emoji, entity_table)
/// ```
///
pub fn entities_from_codepoint(
  codepoint: UtfCodepoint,
  table table: Table,
) -> List(String) {
  let int = string.utf_codepoint_to_int(codepoint)
  let dec = "#" <> int.to_string(int)
  let hex = "#x" <> int.to_base16(int)
  case dict.get(table.from_codepoint, codepoint) {
    Error(_) -> [hex, dec]
    Ok(named_entities) -> [hex, dec, ..named_entities]
  }
  |> list.map(format_entity)
}

fn format_entity(entity: String) {
  "&" <> entity <> ";"
}
