//// Converts between Unicode code points and HTML
//// [entities / character references](https://html.spec.whatwg.org/multipage/named-characters.html).

import gleam/int
import gleam/list
import gleam/result
import gleam/string

@external(javascript, "./html/entity_map.mjs", "codepoint_to_notations")
fn codepoint_to_notations(codepoint: Int) -> Result(List(String), Nil)

@external(javascript, "./html/entity_map.mjs", "notation_to_codepoints")
fn notation_to_codepoints(notation: String) -> Result(List(Int), Nil)

/// Converts an HTML character reference `String` to a `List` of `UtfCodepoint`.
///
/// ## Examples
///
/// ```gleam
/// let star = Ok(string.to_utf_codepoints("\u{22C6}"))  // Ok(['⋆']):
///
/// assert html.entity_to_codepoints("&Star;") == star
///
/// assert html.entity_to_codepoints("&#x22C6;") == star
///
/// assert html.entity_to_codepoints("&#8902;") == star
///
/// assert html.entity_to_codepoints("&Staaar;") == Error(Nil)
///
/// assert html.entity_to_codepoints("Star") == Error(Nil)
/// ```
///
pub fn entity_to_codepoints(entity: String) -> Result(List(UtfCodepoint), Nil) {
  use inner <- result.try(case entity, string.ends_with(entity, ";") {
    "&" <> entity, True -> Ok(string.drop_end(from: entity, up_to: 1))
    _, _ -> Error(Nil)
  })
  case notation_to_codepoints(inner) {
    Ok(codepoints) ->
      list.map(codepoints, string.utf_codepoint)
      |> result.all()
    Error(_) ->
      numeric_entity_to_codepoints(inner)
      |> result.map(list.wrap)
  }
}

fn numeric_entity_to_codepoints(entity: String) -> Result(UtfCodepoint, Nil) {
  case entity {
    "#x" <> hex | "#X" <> hex -> int.base_parse(hex, 16)
    "#" <> dec -> int.parse(dec)
    _ -> Error(Nil)
  }
  |> result.try(string.utf_codepoint)
}

/// Converts an HTML character reference `String` to the escaped string.
///
/// ## Examples
///
/// ```gleam
/// assert html.entity_to_string("&Star;") == Ok("⋆")
///
/// assert html.entity_to_string("&#x22C6;") == Ok("\u{22C6}")
///
/// assert html.entity_to_string("&#8902;") == Ok("\u{22C6}")
///
/// assert html.entity_to_string("&Staaar;") == Error(Nil)
///
/// assert html.entity_to_string("Star") == Error(Nil)
/// ```
///
pub fn entity_to_string(entity: String) -> Result(String, Nil) {
  entity_to_codepoints(entity) |> result.map(string.from_utf_codepoints)
}

/// Converts a `UtfCodepoint` to a `List` of HTML character references `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)  // '⋆'
/// let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)   // '⭐'
///
/// assert html.entities_from_codepoint(star_symbol)
///   |> list.sort(string.compare)
///   == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]
///
/// assert html.entities_from_codepoint(star_emoji)
///   |> list.sort(string.compare)
///   == ["&#11088;", "&#x2B50;"]
/// ```
///
pub fn entities_from_codepoint(codepoint: UtfCodepoint) -> List(String) {
  let cp = string.utf_codepoint_to_int(codepoint)
  let dec = "#" <> int.to_string(cp)
  let hex = "#x" <> int.to_base16(cp)
  case codepoint_to_notations(cp) {
    Error(_) -> [hex, dec]
    Ok(named_entities) -> [hex, dec, ..named_entities]
  }
  |> list.map(format_entity)
}

fn format_entity(entity: String) {
  "&" <> entity <> ";"
}
