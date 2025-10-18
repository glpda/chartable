//// Converts between Unicode code points and HTML
//// [character references (entities)](https://developer.mozilla.org/en-US/docs/Glossary/Character_reference)
//// (see [WHATWG list of named character references](https://html.spec.whatwg.org/multipage/named-characters.html)).

import gleam/int
import gleam/list
import gleam/result
import gleam/string

@external(javascript, "./html/entity_map.mjs", "grapheme_to_notations")
fn grapheme_to_notations(grapheme: String) -> List(String)

@external(javascript, "./html/entity_map.mjs", "notation_to_grapheme")
fn notation_to_grapheme(notation: String) -> Result(String, Nil)

fn format_entity(entity: String) {
  "&" <> entity <> ";"
}

/// Converts a grapheme `String` to a sorted `List` of HTML named character
/// references `String`.
///
/// ## Examples
///
/// ```gleam
/// assert html.named_character_references("⋆")
///   == ["&Star;", "&sstarf;"]
///
/// assert html.named_character_references("⭐") == []
/// ```
///
pub fn named_character_references(grapheme: String) -> List(String) {
  grapheme_to_notations(grapheme)
  |> list.map(format_entity)
}

/// Converts a `UtfCodepoint` to an HTML decimal numeric character reference
/// `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = string.utf_codepoint(11_088)
/// assert html.decimal_character_reference(cp) == "&#11088;"
/// ```
///
pub fn decimal_character_reference(codepoint: UtfCodepoint) -> String {
  let cp = string.utf_codepoint_to_int(codepoint)
  format_entity("#" <> int.to_string(cp))
}

/// Converts a `UtfCodepoint` to an HTML hexadecimal numeric character reference
/// `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = string.utf_codepoint(0x2B50)
/// assert html.decimal_character_reference(cp) == "&#x2B50;"
/// ```
///
pub fn hexadecimal_character_reference(codepoint: UtfCodepoint) -> String {
  let cp = string.utf_codepoint_to_int(codepoint)
  format_entity("#x" <> int.to_base16(cp))
}

/// Converts a `UtfCodepoint` to a `List` of HTML character references `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(star_symbol) = string.utf_codepoint(0x22C6)
/// let assert Ok(star_emoji) = string.utf_codepoint(0x2B50)
///
/// assert html.character_references_from_codepoint(star_symbol)
///   |> list.sort(string.compare)
///   == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]
///
/// assert html.character_references_from_codepoint(star_emoji)
///   |> list.sort(string.compare)
///   == ["&#11088;", "&#x2B50;"]
/// ```
///
pub fn character_references_from_codepoint(
  codepoint: UtfCodepoint,
) -> List(String) {
  let grapheme = string.from_utf_codepoints([codepoint])
  let dec = decimal_character_reference(codepoint)
  let hex = hexadecimal_character_reference(codepoint)
  let names = named_character_references(grapheme)
  [dec, hex, ..names]
}

/// Converts a grapheme `String` to a `List` of HTML character references
/// `String`.
///
/// ## Examples
///
/// ```gleam
/// assert html.character_references_from_grapheme("⋆")
///   |> list.sort(string.compare)
///   == ["&#8902;", "&#x22C6;", "&Star;", "&sstarf;"]
///
/// assert html.character_references_from_grapheme("⭐")
///   |> list.sort(string.compare)
///   == ["&#11088;", "&#x2B50;"]
/// ```
///
pub fn character_references_from_grapheme(grapheme: String) -> List(String) {
  let codepoints = string.to_utf_codepoints(grapheme)
  let dec =
    list.map(codepoints, decimal_character_reference)
    |> string.concat()
  let hex =
    list.map(codepoints, hexadecimal_character_reference)
    |> string.concat()
  let names = named_character_references(grapheme)
  [dec, hex, ..names]
}

/// Converts an HTML character reference `String` to a grapheme `String`.
///
/// ## Examples
///
/// ```gleam
/// assert html.character_reference_to_grapheme("&Star;") == Ok("⋆")
///
/// assert html.character_reference_to_grapheme("&#x22C6;") == Ok("\u{22C6}")
///
/// assert html.character_reference_to_grapheme("&#8902;") == Ok("\u{22C6}")
///
/// assert html.character_reference_to_grapheme("&Staaar;") == Error(Nil)
///
/// assert html.character_reference_to_grapheme("Star") == Error(Nil)
/// ```
///
pub fn character_reference_to_grapheme(entity: String) -> Result(String, Nil) {
  use inner <- result.try(case entity, string.ends_with(entity, ";") {
    "&" <> entity, True -> Ok(string.drop_end(from: entity, up_to: 1))
    _, _ -> Error(Nil)
  })
  case inner {
    "#x" <> hex | "#X" <> hex ->
      int.base_parse(hex, 16)
      |> result.try(string.utf_codepoint)
      |> result.map(fn(codepoint) { string.from_utf_codepoints([codepoint]) })
    "#" <> dec ->
      int.parse(dec)
      |> result.try(string.utf_codepoint)
      |> result.map(fn(codepoint) { string.from_utf_codepoints([codepoint]) })
    _ -> notation_to_grapheme(inner)
  }
}
