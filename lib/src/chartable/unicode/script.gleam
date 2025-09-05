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
