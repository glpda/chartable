import chartable/latex/math_type.{type MathType}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// TeX category codes used when parsing characters,
/// see [LaTeX](https://en.wikibooks.org/wiki/LaTeX/Plain_TeX#Catcodes)
/// and [plain Tex](https://en.wikibooks.org/wiki/TeX/catcode) wikibooks.
pub type CatCode {
  /// 0: escape character used to start a command,
  /// by default U+005C ( \ )
  Escape
  /// 1: beginning of a group,
  /// by default U+007B ( { )
  BeginGroup
  /// 2: end of a group,
  /// by default U+007D ( } ).
  EndGroup
  /// 3: shift in and out of math mode,
  /// by default U+0024 ( $ ).
  MathShift
  /// 4: alignement of tables and equations,
  /// by default U+0026 ( & ).
  Alignment
  /// 5: end of line,
  /// by default U+000D (CR).
  EndLine
  /// 6: parameter for macros,
  /// by default U+0023 ( # ).
  MacroParameter
  /// 7: mathematics superscript,
  /// by default U+005E ( ^ ) and U+000B (VT).
  Superscript
  /// 8: mathematics subscript,
  /// by default U+005F ( _ ) and U+0001 (SOH).
  Subscript
  /// 9: ignored characters,
  /// by default U+0000 (NULL).
  Ignored
  /// 10: space characters,
  /// by default U+0020 (SPACE) and U+0009 (TAB).
  Space
  /// 11: ASCII letters, A...Z and a...z, which can be be used in command names.
  Letter
  /// 12: other characters, numbers, punctuations,
  /// and most notably U+0040 ( @ ).
  Other
  /// 13: active characters, can be assigned a command,
  /// by default U+007E ( ~ ) and U+000C (FF).
  Active
  /// 14: comment character,
  /// by default U+0025 ( % ).
  Comment
  /// 15: invalid characters,
  /// by default U+007F (DEL).
  Invalid
}

/// Returns the default category code of a given codepoint, note that TeX
/// allows to change the category of any characters with the `\catcode` command.
pub fn catcode_from_codepoint(codepoint: UtfCodepoint) -> CatCode {
  let cp = string.utf_codepoint_to_int(codepoint)
  case cp {
    0x5C -> Escape
    0x7B -> BeginGroup
    0x7D -> EndGroup
    0x24 -> MathShift
    0x26 -> Alignment
    0x0D -> EndLine
    0x23 -> MacroParameter
    0x5E | 0x0B -> Superscript
    0x5F | 0x01 -> Subscript
    0x00 -> Ignored
    0x20 | 0x09 -> Space
    _ if 0x41 <= cp && cp <= 0x5A || 0x61 <= cp && cp <= 0x7A -> Letter
    0x7E | 0x0C -> Active
    0x25 -> Comment
    0x7F -> Invalid
    _ -> Other
  }
}

/// Returns the integer code of a given TeX category code.
pub fn catcode_to_int(cat: CatCode) -> Int {
  case cat {
    Escape -> 0
    BeginGroup -> 1
    EndGroup -> 2
    MathShift -> 3
    Alignment -> 4
    EndLine -> 5
    MacroParameter -> 6
    Superscript -> 7
    Subscript -> 8
    Ignored -> 9
    Space -> 10
    Letter -> 11
    Other -> 12
    Active -> 13
    Comment -> 14
    Invalid -> 15
  }
}

/// Returns the TeX category code of a given integer code.
pub fn catcode_from_int(int: Int) -> Result(CatCode, Nil) {
  case int {
    0x0 -> Ok(Escape)
    0x1 -> Ok(BeginGroup)
    0x2 -> Ok(EndGroup)
    0x3 -> Ok(MathShift)
    0x4 -> Ok(Alignment)
    0x5 -> Ok(EndLine)
    0x6 -> Ok(MacroParameter)
    0x7 -> Ok(Superscript)
    0x8 -> Ok(Subscript)
    0x9 -> Ok(Ignored)
    0xA -> Ok(Space)
    0xB -> Ok(Letter)
    0xC -> Ok(Other)
    0xD -> Ok(Active)
    0xE -> Ok(Comment)
    0xF -> Ok(Invalid)
    _ -> Error(Nil)
  }
}

// =============================================================================
// BEGIN Codepoint/Grapheme -> TeX/LaTeX

/// Returns the TeX escape command `\char<number>` for a given codepoint,
/// see [TeX wikibook](https://en.wikibooks.org/wiki/TeX/char).
pub fn char_escape(codepoint: UtfCodepoint) -> String {
  let cp = string.utf_codepoint_to_int(codepoint)
  "\\char" <> int.to_string(cp)
}

@external(javascript, "./latex/unimath_map.mjs", "codepoint_to_notations")
fn codepoint_to_unimath_ffi(cp: Int) -> List(String)

/// Get the unicode-math commands outputting a given code point.
pub fn unimath_from_codepoint(cp: UtfCodepoint) -> List(String) {
  string.utf_codepoint_to_int(cp)
  |> codepoint_to_unimath_ffi
  |> list.map(string.append(_, to: "\\"))
}

// END

// =============================================================================
// BEGIN TeX/LaTeX -> Grapheme

/// Returns the grapheme represented by a TeX/LaTeX command in text mode.
///
/// This is not a TeX parser! Some commands can be directly followed by other
/// characters without issue, but this function does not handle such cases.
pub fn text_to_grapheme(latex: String) -> Result(String, Nil) {
  case latex {
    "~" -> Ok("\u{00A0}")
    "-" -> Ok(" \u{2010}")
    "--" -> Ok("\u{2013}")
    "---" -> Ok("\u{2014}")
    "`" -> Ok("\u{2018}")
    "'" -> Ok("\u{2019}")
    "``" -> Ok("\u{201C}")
    "''" -> Ok("\u{201D}")
    "\\" <> command -> text_command_to_grapheme(command)
    _ -> Error(Nil)
  }
}

fn text_command_to_grapheme(command: String) -> Result(String, Nil) {
  case command {
    " " -> Ok(" ")
    "space" -> Ok(" ")
    "-" -> Ok("\u{00AD}")
    "char" <> dec -> {
      use int <- result.try(int.parse(dec))
      use cp <- result.map(string.utf_codepoint(int))
      string.from_utf_codepoints([cp])
    }
    _ -> Error(Nil)
  }
}

/// Returns the grapheme represented by a TeX/LaTeX command in math mode.
///
/// This is not a TeX parser! Some commands can be directly followed by other
/// characters without issue, but this function does not handle such cases.
pub fn math_to_grapheme(latex: String) {
  case latex {
    "'" -> Ok("\u{2032}")
    "''" -> Ok("\u{2033}")
    "'''" -> Ok("\u{2034}")
    "\\" <> command -> math_command_to_grapheme(command)
    _ -> Error(Nil)
  }
}

fn math_command_to_grapheme(command: String) -> Result(String, Nil) {
  case command {
    " " -> Ok(" ")
    "space" -> Ok(" ")
    "char" <> dec -> {
      use int <- result.try(int.parse(dec))
      use cp <- result.map(string.utf_codepoint(int))
      string.from_utf_codepoints([cp])
    }
    _ -> unimath_to_grapheme(command)
  }
}

@external(javascript, "./latex/unimath_map.mjs", "notation_to_codepoint_type")
fn unimath_to_codepoint_type_ffi(
  notation: String,
) -> Result(#(Int, MathType), Nil)

/// Returns the LaTeX math type and code point of a given unicode-math command.
pub fn unimath(command: String) -> Result(#(MathType, UtfCodepoint), Nil) {
  use #(cp, math_type) <- result.try(unimath_to_codepoint_type_ffi(command))
  use codepoint <- result.map(string.utf_codepoint(cp))
  #(math_type, codepoint)
}

fn unimath_to_grapheme(command: String) -> Result(String, Nil) {
  use #(_, codepoint) <- result.map(unimath(command))
  string.from_utf_codepoints([codepoint])
}
// END
