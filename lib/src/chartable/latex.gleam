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

/// Get the short control escape of a code point, see
/// [TeX for the Impatient](https://mirrors.ctan.org/info/impatient/book.pdf)
/// page 55.
///
/// Returns an `Error` if the code point is greater than U+0080.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = string.utf_codepoint(0x001B)
/// assert latex.short_control_escape(cp) == Ok("^^[")
/// ```
///
pub fn short_control_escape(codepoint: UtfCodepoint) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    i if i < 0x40 -> {
      use cp <- result.try(string.utf_codepoint(i + 0x40))
      Ok("^^" <> string.from_utf_codepoints([cp]))
    }
    i if i < 0x80 -> {
      use cp <- result.try(string.utf_codepoint(i - 0x40))
      Ok("^^" <> string.from_utf_codepoints([cp]))
    }
    _ -> Error(Nil)
  }
}

/// Get the long control escape of a code point, see
/// [TeX for the Impatient](https://mirrors.ctan.org/info/impatient/book.pdf)
/// page 55.
///
/// Returns an `Error` if the code point is greater than U+0100.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = string.utf_codepoint(0x001B)
/// assert latex.long_control_escape(cp) == Ok("^^1b")
/// ```
///
pub fn long_control_escape(codepoint: UtfCodepoint) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    i if i < 0x100 -> {
      let hex =
        int.to_base16(i)
        |> string.lowercase
        |> string.pad_start(to: 2, with: "0")
      Ok("^^" <> hex)
    }
    _ -> Error(Nil)
  }
}

/// Returns the TeX escape command `\char<number>` for a given codepoint,
/// see [TeX wikibook](https://en.wikibooks.org/wiki/TeX/char).
pub fn char_escape(codepoint: UtfCodepoint) -> String {
  let cp = string.utf_codepoint_to_int(codepoint)
  "\\char" <> int.to_string(cp)
}

@external(javascript, "./latex/unimath_map.mjs", "codepoint_to_notations")
fn codepoint_to_unimath_ffi(cp: Int) -> List(String)

/// Get the [unicode-math](https://ctan.org/pkg/unicode-math) commands
/// outputting a given code point.
pub fn unimath_from_codepoint(cp: UtfCodepoint) -> List(String) {
  string.utf_codepoint_to_int(cp)
  |> codepoint_to_unimath_ffi
  |> list.map(string.append(_, to: "\\"))
}

// END

// =============================================================================
// BEGIN TeX/LaTeX -> Grapheme

/// Parses the control escape sequences in a string, see
/// [TeX for the Impatient](https://mirrors.ctan.org/info/impatient/book.pdf)
/// page 55.
///
pub fn parse_control_escape(str: String) -> String {
  string.to_utf_codepoints(str)
  |> list.map(string.utf_codepoint_to_int)
  |> parse_control_escape_loop([])
  // NOTE: the ints should all be valid codepoints
  |> list.try_map(string.utf_codepoint)
  |> result.unwrap([])
  |> string.from_utf_codepoints
}

fn parse_control_escape_loop(
  codepoints: List(Int),
  acc acc: List(Int),
) -> List(Int) {
  // TODO maybe use BitArray instead of List(Int)
  case codepoints {
    // NOTE: 'x' & 'y' must be lowercase letters or numbers
    [94, 94, x, y, ..rest] if 48 <= x && x < 58 && 48 <= y && y < 58 ->
      parse_control_escape_loop(rest, [{ x - 48 } * 16 + { y - 48 }, ..acc])
    [94, 94, x, y, ..rest] if 48 <= x && x < 58 && 97 <= y && y < 103 ->
      parse_control_escape_loop(rest, [{ x - 48 } * 16 + { y - 87 }, ..acc])
    [94, 94, x, y, ..rest] if 97 <= x && x < 103 && 48 <= y && y < 58 ->
      parse_control_escape_loop(rest, [{ x - 87 } * 16 + { y - 48 }, ..acc])
    [94, 94, x, y, ..rest] if 97 <= x && x < 103 && 97 <= y && y < 103 ->
      parse_control_escape_loop(rest, [{ x - 87 } * 16 + { y - 87 }, ..acc])
    [94, 94, x, ..rest] if x < 64 ->
      parse_control_escape_loop(rest, [x + 64, ..acc])
    [94, 94, x, ..rest] if x < 128 ->
      parse_control_escape_loop(rest, [x - 64, ..acc])
    [94, 94] -> list.reverse(acc)
    [cp, ..rest] -> parse_control_escape_loop(rest, acc: [cp, ..acc])
    [] -> list.reverse(acc)
  }
}

fn any_to_grapheme(latex: String) -> Result(String, Nil) {
  case latex {
    "`" -> Ok("\u{2018}")
    "\\" <> command -> any_command_to_grapheme(command)
    _ -> Error(Nil)
  }
}

fn any_command_to_grapheme(command: String) -> Result(String, Nil) {
  case command {
    // special symbols:
    "#" -> Ok("#")
    "$" -> Ok("$")
    "%" -> Ok("%")
    "&" -> Ok("&")
    "_" -> Ok("_")
    "lq" -> Ok("‘")
    "rq" -> Ok("’")
    "lbrack" -> Ok("[")
    "rbrack" -> Ok("]")
    "dag" -> Ok("†")
    "ddag" -> Ok("‡")
    "copyright" -> Ok("©")
    "P" -> Ok("¶")
    "S" -> Ok("§")
    "dots" -> Ok("…")
    "slash" -> Ok("/")

    // spacing:
    " " | "space" -> Ok(" ")
    // ⅙em:
    "thinspace" -> Ok("\u{2006}")
    // ½em: Ok("\u{2000}")
    "enskip" | "enspace" -> Ok("\u{2002}")
    // 1em: Ok("\u{2001}")
    "quad" -> Ok("\u{2003}")
    // 2em:
    "qquad" -> Ok("\u{2003}\u{2003}")

    // char escape:
    "char" <> dec -> {
      use int <- result.try(int.parse(dec))
      use cp <- result.try(string.utf_codepoint(int))
      Ok(string.from_utf_codepoints([cp]))
    }
    _ -> Error(Nil)
  }
}

/// Returns the grapheme represented by a TeX/LaTeX command in text mode.
///
/// This is not a TeX parser! Some commands can be directly followed by other
/// characters without issue, but this function does not handle such cases.
pub fn text_to_grapheme(latex: String) -> Result(String, Nil) {
  let latex = parse_control_escape(latex)
  use <- result.lazy_or(any_to_grapheme(latex))
  case latex {
    "~" -> Ok("\u{00A0}")
    "-" -> Ok(" \u{2010}")
    "--" -> Ok("\u{2013}")
    "---" -> Ok("\u{2014}")
    "'" -> Ok("\u{2019}")
    "``" -> Ok("\u{201C}")
    "''" -> Ok("\u{201D}")

    "\\" <> command -> text_command_to_grapheme(command)
    _ -> Error(Nil)
  }
}

fn text_command_to_grapheme(command: String) -> Result(String, Nil) {
  case command {
    // soft hyphen:
    "-" -> Ok("\u{00AD}")
    // letters and ligatures:
    "AA" -> Ok("Å")
    "aa" -> Ok("å")
    "AE" -> Ok("Æ")
    "ae" -> Ok("æ")
    "L" -> Ok("Ł")
    "l" -> Ok("ł")
    "O" -> Ok("Ø")
    "o" -> Ok("ø")
    "OE" -> Ok("Œ")
    "oe" -> Ok("œ")
    "ss" -> Ok("ß")
    "i" -> Ok("ı")
    "j" -> Ok("ȷ")

    _ -> Error(Nil)
  }
}

/// Returns the grapheme represented by a TeX/LaTeX command in math mode.
///
/// This is not a TeX parser! Some commands can be directly followed by other
/// characters without issue, but this function does not handle such cases.
pub fn math_to_grapheme(latex: String) {
  let latex = parse_control_escape(latex)
  use <- result.lazy_or(any_to_grapheme(latex))
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
    // negative thin space:
    // "!" -> Ok("\u{200B}")
    // thin space:
    "," -> Ok("\u{202F}")
    // medium space:
    ">" -> Ok("\u{205F}")
    // thick space:
    ";" -> Ok("\u{2004}")
    // discretionary multiplication symbol:
    "*" -> Ok("\u{2062}")
    // negation overlay accent:
    "not" -> Ok("\u{0338}")
    _ -> unimath_to_grapheme(command)
  }
}

@external(javascript, "./latex/unimath_map.mjs", "notation_to_mathtype_codepoint")
fn unimath_to_mathtype_codepoint_ffi(
  notation: String,
) -> Result(#(MathType, Int), Nil)

/// Returns the LaTeX math type and code point of a given
/// [unicode-math](https://ctan.org/pkg/unicode-math) command.
pub fn unimath(command: String) -> Result(#(MathType, UtfCodepoint), Nil) {
  use #(math_type, cp) <- result.try(unimath_to_mathtype_codepoint_ffi(command))
  use codepoint <- result.try(string.utf_codepoint(cp))
  Ok(#(math_type, codepoint))
}

fn unimath_to_grapheme(command: String) -> Result(String, Nil) {
  use #(_, codepoint) <- result.try(unimath(command))
  Ok(string.from_utf_codepoints([codepoint]))
}
// END
