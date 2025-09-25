import chartable/latex/math_type.{type MathType}
import gleam/list
import gleam/result
import gleam/string

@external(javascript, "./latex/unimath_map.mjs", "codepoint_to_notations")
fn codepoint_to_notations_ffi(cp: Int) -> List(String)

/// Get the unicode-math commands outputting a given code point.
pub fn unimath_from_codepoint(cp: UtfCodepoint) -> List(String) {
  string.utf_codepoint_to_int(cp)
  |> codepoint_to_notations_ffi
  |> list.map(string.append(_, to: "\\"))
}

/// Get the unicode-math commands outputting a given grapheme.
pub fn unimath_from_grapheme(grapheme: String) -> List(String) {
  case string.to_utf_codepoints(grapheme) {
    [cp] -> unimath_from_codepoint(cp)
    _ -> []
  }
}

@external(javascript, "./latex/unimath_map.mjs", "notation_to_codepoint_type")
fn notation_to_codepoint_type_ffi(
  notation: String,
) -> Result(#(Int, MathType), Nil)

/// Returns the LaTeX math type and code point of a given unicode-math command.
pub fn unimath(notation: String) -> Result(#(MathType, UtfCodepoint), Nil) {
  use #(cp, math_type) <- result.try(notation_to_codepoint_type_ffi(notation))
  use codepoint <- result.map(string.utf_codepoint(cp))
  #(math_type, codepoint)
}

/// Get the LaTeX math type of a given unicode-math command.
pub fn unimath_to_math_type(notation: String) -> Result(MathType, Nil) {
  use #(_, math_type) <- result.map(notation_to_codepoint_type_ffi(notation))
  math_type
}

/// Get the code point outputted by a given unicode-math command.
pub fn unimath_to_codepoint(notation: String) -> Result(UtfCodepoint, Nil) {
  use #(codepoint, _) <- result.try(notation_to_codepoint_type_ffi(notation))
  string.utf_codepoint(codepoint)
}

/// Get the grapheme outputted by a given unicode-math command.
pub fn unimath_to_grapheme(notation: String) -> Result(String, Nil) {
  use codepoint <- result.map(unimath_to_codepoint(notation))
  string.from_utf_codepoints([codepoint])
}
