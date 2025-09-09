//// [Unicode Script Property](https://www.unicode.org/reports/tr24):
//// collection of letters and other written signs sharing common history and
//// used in one or more writing systems.
////
//// Scripts can be scattered accross multiple blocks,
//// and one block can contain multiple scripts.

import chartable/internal
import gleam/list
import gleam/string

pub opaque type Script {
  /// name: lowercase short name
  Script(name: String)
}

/// list of lowercase short names
@external(javascript, "./script_map.mjs", "get_list")
fn get_list() -> List(String)

/// lowercase short name -> full long name
@external(javascript, "./script_map.mjs", "short_name_to_long_name")
fn short_name_to_long_name(script: String) -> Result(String, Nil)

/// "comparable" long name -> lowercase short name
@external(javascript, "./script_map.mjs", "long_name_to_short_name")
fn long_name_to_short_name(script: String) -> Result(String, Nil)

/// int codepoint -> lowercase short name ("zzzz" if not assigned)
@external(javascript, "./script_map.mjs", "codepoint_to_script")
fn codepoint_to_script(cp: Int) -> String

/// lowercase short name -> list int-range tuples
@external(javascript, "./script_map.mjs", "script_to_ranges")
fn script_to_ranges(script: String) -> List(#(Int, Int))

/// Get a list of all [`Script`](#Script) values.
pub fn list() -> List(Script) {
  list.map(get_list(), Script)
}

/// Converts a script name `String` to a [`Script`](#Script) value,
/// script's name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(common) = script.from_name("zyyy")
/// assert Ok(common) == script.from_name("_Common_")
/// ```
///
pub fn from_name(str: String) -> Result(Script, Nil) {
  let str = internal.comparable_property(str)
  case short_name_to_long_name(str) {
    Ok(_) -> Ok(Script(str))
    Error(_) ->
      case long_name_to_short_name(str) {
        Ok(short) -> Ok(Script(short))
        Error(_) ->
          case str {
            "qaac" -> Ok(Script("copt"))
            "qaai" -> Ok(Script("zinh"))
            _ -> Error(Nil)
          }
      }
  }
}

/// Returns the short name `String` of a [`Script`](#Script) value
/// (a capitalised 4-letter code).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(common) = script.from_name("zyyy")
/// assert script.to_short_name(common) == "Zyyy"
/// ```
///
pub fn to_short_name(script: Script) -> String {
  string.capitalise(script.name)
}

/// Returns the long name `String` of a [`Script`](#Script) value.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(common) = script.from_name("zyyy")
/// assert script.to_long_name(common) == "Common"
/// ```
///
pub fn to_long_name(script: Script) -> String {
  case short_name_to_long_name(script.name) {
    Ok(str) -> str
    // Error should not be possible.
    Error(_) -> script.name
  }
}

/// Get the [`Script`](#Script) value of a given codepoint.
/// Returns `"Zzzz"` (Unknown) if the code point is not assigned.
///
/// ## Examples
///
/// ```gleam
/// use cp <- result.map(string.utf_codepoint(0x0041))
/// let latin = script.from_codepoint(cp)
/// assert script.to_long_name(latin) == "Latin"
/// ```
///
pub fn from_codepoint(cp: UtfCodepoint) -> Script {
  string.utf_codepoint_to_int(cp) |> codepoint_to_script |> Script
}

/// Get the [`Script`](#Script) value of a given codepoint.
/// Returns `Ok("Zzzz")` (Unknown) if the code point is not assigned,
/// and `Error(Nil)` if the integer does not represent a valid code point.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(common) = script.from_int(0x0020)
/// assert script.to_short_name(common) == "Zyyy"
///
/// let assert Ok(latin) = script.from_int(0x0041)
/// assert script.to_long_name(latin) == "Latin"
/// ```
///
pub fn from_int(cp: Int) -> Result(Script, Nil) {
  case cp {
    cp if cp < 0 || 0x10FFFF < cp -> Error(Nil)
    cp -> codepoint_to_script(cp) |> Script |> Ok
  }
}

/// Get the list of code point ranges `#(start, end)` of a [`Script`](#Script)
/// value (sorted in ascending order).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(braille) = script.from_name("braille")
/// assert script.to_pairs(braille) == [#(0x2800, 0x28FF)]
///
/// let assert Ok(hiragana) = script.from_name("Hira")
/// assert script.to_pairs(hiragana)
///   == [
///     #(0x3041, 0x3096),
///     #(0x309D, 0x309F),
///     #(0x1B001, 0x1B11F),
///     #(0x1B132, 0x1B132),
///     #(0x1B150, 0x1B152),
///     #(0x1F200, 0x1F200),
///   ]
/// ```
///
pub fn to_pairs(script: Script) -> List(#(Int, Int)) {
  script_to_ranges(script.name)
}
