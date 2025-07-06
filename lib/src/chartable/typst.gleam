//// Converts between Unicode code points and [typst notations](https://typst.app/docs/reference)

import chartable/internal/math_alphanum.{Bold, Italic, Regular, Upright}
import chartable/typst/emoji
import chartable/typst/sym
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import splitter.{split}

/// Maps code points to typst codex identifiers.
///
/// Prefer [`notations_from_codepoint`](#notations_from_codepoint)
/// over direclty working with table dictionaries.
pub type FromCodepoint =
  Dict(UtfCodepoint, List(String))

/// Maps typst codex identifiers to code points.
///
/// Prefer [`notation_to_codepoint`](#notation_to_codepoint)
/// over direclty working with table dictionaries.
pub type ToCodepoints =
  Dict(String, List(UtfCodepoint))

/// Maps code points to typst codex identifiers and the other way around.
pub type Table {
  Table(from_codepoint: FromCodepoint, to_codepoints: ToCodepoints)
}

pub opaque type Tables {
  Tables(emojitable: Table, symtable: Table)
}

/// The parser is only called on constant input fetched from
/// [typst codex source code](https://github.com/typst/codex)
/// and tested before release.
/// It is therefore safe to assume parsing will not return an error
/// and assert the result of `typst.make_*table()`
pub type ParserError {
  SubmoduleNotOpen(line: Int)
  SubmoduleNotClosed(line: Int)
  InvalidCodepoints(line: Int)
  InvalidIdentifier(line: Int)
  DuplicateIdentifier(line: Int)
}

type ParserState {
  ParserState(
    line: Int,
    txt: String,
    prefix: String,
    submodule: String,
    pair: Option(#(List(UtfCodepoint), String)),
  )
}

fn start_parser(txt: String) -> ParserState {
  ParserState(line: 0, txt:, prefix: "", submodule: "", pair: None)
}

fn next_line(state state: ParserState, rest txt: String) -> ParserState {
  ParserState(..state, txt:, line: state.line + 1, pair: None)
}

/// Makes symbol table. Requires parsing `sym.txt` from typst codex:
/// for better performance, call only once and keep the dictionary.
/// Only handles names listed in
/// [this module](https://typst.app/docs/reference/symbols/sym/).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(symtable) = typst.make_symtable()
///
/// assert Ok(["star.op"])
///   == string.utf_codepoint(0x22C6)
///   |> result.try(dict.get(symtable.from_codepoint, _))
///
/// assert Ok(string.to_utf_codepoints("\u{22C6}"))
///   == dict.get(symtable.to_codepoints, "star.op")
///
/// ```
///
pub fn make_symtable() -> Result(Table, ParserError) {
  parse_codex(sym.txt)
}

/// Makes emoji table. Requires parsing `emoji.txt` from typst codex:
/// for better performance, call only once and keep the dictionary.
/// Only handles names listed in
/// [this module](https://typst.app/docs/reference/symbols/emoji/).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(emojitable) = typst.make_emojitable()
///
/// assert Ok(["star.glow"])
///   == string.utf_codepoint(0x1F31F)
///   |> result.try(dict.get(emojitable.from_codepoint, _))
///
/// assert Ok(string.to_utf_codepoints("\u{1F31F}"))
///   == dict.get(emojitable.to_codepoints, "star.glow")
/// ```
///
pub fn make_emojitable() -> Result(Table, ParserError) {
  parse_codex(emoji.txt)
}

pub fn make_tables() -> Result(Tables, ParserError) {
  use symtable <- result.try(make_symtable())
  use emojitable <- result.try(make_emojitable())

  Ok(Tables(emojitable:, symtable:))
}

fn parse_codex(txt: String) -> Result(Table, ParserError) {
  let table = Table(dict.new(), dict.new())
  let line_ends = splitter.new(["\n", "\r\n"])
  let comments = splitter.new(["//", "@"])
  let space = splitter.new([" "])

  use state <- parse(input: start_parser(txt), output: table)
  let #(line, _, rest) = split(line_ends, state.txt)
  let #(line, _, _) = split(comments, line)
  let line = string.trim(line)
  case line {
    "" -> Ok(next_line(state:, rest:))
    "}" <> _ if state.submodule != "" ->
      Ok(ParserState(..next_line(state:, rest:), submodule: ""))
    "}" <> _ -> Error(SubmoduleNotOpen(state.line))
    line -> {
      let #(key, _, symbol) = split(space, line)
      case key, symbol {
        "", _ -> Ok(next_line(state:, rest:))
        "." <> suffix, symbol ->
          parse_codepoints(symbol, [])
          |> result.replace_error(InvalidCodepoints(state.line))
          |> result.map(fn(codepoints) {
            ParserState(
              ..next_line(state:, rest:),
              pair: Some(#(codepoints, suffix)),
            )
          })
        prefix, "" -> Ok(ParserState(..next_line(state:, rest:), prefix:))
        submodule, "{" ->
          Ok(ParserState(..next_line(state:, rest:), prefix: "", submodule:))
        prefix, symbol ->
          parse_codepoints(symbol, [])
          |> result.replace_error(InvalidCodepoints(state.line))
          |> result.map(fn(codepoints) {
            ParserState(
              ..next_line(state:, rest:),
              prefix:,
              pair: Some(#(codepoints, "")),
            )
          })
      }
    }
  }
}

fn parse_codepoints(
  string: String,
  acc: List(UtfCodepoint),
) -> Result(List(UtfCodepoint), Nil) {
  case string {
    "" ->
      case acc {
        [] -> Error(Nil)
        _ -> Ok(acc)
      }
    "\\u{" <> rest -> {
      use #(hex_code, rest) <- result.try(string.split_once(rest, on: "}"))
      use number <- result.try(int.base_parse(hex_code, 16))
      use codepoint <- result.try(string.utf_codepoint(number))
      parse_codepoints(rest, [codepoint, ..acc])
    }
    string -> {
      use #(grapheme, rest) <- result.try(string.pop_grapheme(string))
      let acc = list.append(acc, string.to_utf_codepoints(grapheme))
      parse_codepoints(rest, acc)
    }
  }
}

fn parse(
  input state: ParserState,
  output table: Table,
  with parser: fn(ParserState) -> Result(ParserState, ParserError),
) -> Result(Table, ParserError) {
  // NOTE: could be more readable with `use` but tail call recursion would be
  //       trickier than with nested `case`.
  case state.txt {
    "" if state.submodule != "" -> Error(SubmoduleNotClosed(state.line))
    "" -> Ok(table)
    _ -> {
      case parser(state) {
        Error(error) -> Error(error)
        Ok(state) -> {
          case state.pair {
            None -> parse(input: state, output: table, with: parser)
            Some(#(codepoints, suffix)) ->
              case make_identifier(state.submodule, state.prefix, suffix) {
                Error(_) -> Error(InvalidIdentifier(state.line))
                Ok(identifier) -> {
                  case table.to_codepoints |> dict.has_key(identifier) {
                    True -> Error(DuplicateIdentifier(state.line))
                    False ->
                      parse(
                        input: state,
                        output: update_table(table, codepoints, identifier),
                        with: parser,
                      )
                  }
                }
              }
          }
        }
      }
    }
  }
}

fn make_identifier(submodule: String, prefix: String, suffix: String) {
  // TODO: test if identifier is ascii letter only (prefix split on: ".").
  // NOTE: validating input will slow down parsing and should not be needed
  //       because we control the parsed input txt.
  case submodule, prefix, suffix {
    "", "", _ -> Error(Nil)
    "", prefix, "" -> Ok(prefix)
    "", prefix, suffix -> Ok(prefix <> "." <> suffix)
    _, "", _ -> Error(Nil)
    submodule, prefix, "" -> Ok(submodule <> "." <> prefix)
    submodule, prefix, suffix -> Ok(submodule <> "." <> prefix <> "." <> suffix)
  }
}

/// Updates table with a new codepoint-notation pair
fn update_table(table: Table, codepoints: List(UtfCodepoint), notation: String) {
  let from_codepoint = case codepoints {
    [codepoint] ->
      dict.upsert(codepoint, in: table.from_codepoint, with: fn(option) {
        case option {
          None -> [notation]
          Some(list) -> [notation, ..list]
        }
      })
    _ -> table.from_codepoint
  }

  let to_codepoints =
    dict.insert(codepoints, into: table.to_codepoints, for: notation)
  Table(from_codepoint:, to_codepoints:)
}

/// Converts a Typst markup mode shorthand `String` to a `UtfCodepoint`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// let en_dash = string.utf_codepoint(0x2013)  // Ok('–')
///
/// assert en_dash == typst.markup_shorthand_to_codepoint("--")
/// ```
///
pub fn markup_shorthand_to_codepoint(
  shorthand: String,
) -> Result(UtfCodepoint, Nil) {
  case shorthand {
    // en dash (–):
    "--" -> string.utf_codepoint(0x2013)
    // em dash (—):
    "---" -> string.utf_codepoint(0x2014)
    // horizontal ellipsis (…):
    "..." -> string.utf_codepoint(0x2026)
    // soft hyphen (shy):
    "-?" -> string.utf_codepoint(0x00AD)
    // minus sign (−):
    "-" -> string.utf_codepoint(0x2212)
    // no break space (nbsp):
    "~" -> string.utf_codepoint(0x00A0)
    _ -> Error(Nil)
  }
}

/// Converts a `UtfCodepoint` to a Typst markup mode shorthand `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(en_dash) = string.utf_codepoint(0x2013)  // '–'
///
/// assert Ok("--") == typst.markup_shorthand_from_codepoint(en_dash)
/// ```
///
pub fn markup_shorthand_from_codepoint(
  codepoint: UtfCodepoint,
) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    // en dash (–):
    0x2013 -> Ok("--")
    // em dash (—):
    0x2014 -> Ok("---")
    // horizontal ellipsis (…):
    0x2026 -> Ok("...")
    // soft hyphen (shy):
    0x00AD -> Ok("-?")
    // minus sign (−):
    0x2212 -> Ok("-")
    // no break space (nbsp):
    0x00A0 -> Ok("~")
    _ -> Error(Nil)
  }
}

/// Converts a Typst math mode shorthand `String` to a `UtfCodepoint`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// let arrow = string.utf_codepoint(0x2192)  // Ok('→')
///
/// assert arrow == typst.math_shorthand_to_codepoint("->")
/// ```
///
pub fn math_shorthand_to_codepoint(
  shorthand: String,
) -> Result(UtfCodepoint, Nil) {
  case shorthand {
    // rightwards arrow (→):
    "->" -> string.utf_codepoint(0x2192)
    // rightwards arrow from bar (↦):
    "|->" -> string.utf_codepoint(0x21A6)
    // rightwards double arrow (⇒):
    "=>" -> string.utf_codepoint(0x21D2)
    // rightwards double arrow from bar (⤇):
    "|=>" -> string.utf_codepoint(0x2907)
    // long rightwards double arrow (⟹):
    "==>" -> string.utf_codepoint(0x27F9)
    // long rightwards arrow (⟶):
    "-->" -> string.utf_codepoint(0x27F6)
    // long rightwards squiggle arrow (⟿):
    "~~>" -> string.utf_codepoint(0x27FF)
    // rightwards squiggle arrow (⇝):
    "~>" -> string.utf_codepoint(0x21DD)
    // rightwards arrow with tail (↣):
    ">->" -> string.utf_codepoint(0x21A3)
    // rightwards two headed arrow (↠):
    "->>" -> string.utf_codepoint(0x21A0)
    // leftwards arrow (←):
    "<-" -> string.utf_codepoint(0x2190)
    // leftwards long double arrow (⟸):
    "<==" -> string.utf_codepoint(0x27F8)
    // long leftwards arrow (⟵):
    "<--" -> string.utf_codepoint(0x27F5)
    // long leftwards squiggle arrow (⬳):
    "<~~" -> string.utf_codepoint(0x2B33)
    // leftwards squiggle arrow (⇜):
    "<~" -> string.utf_codepoint(0x21DC)
    // leftwards arrow with tail (↢):
    "<-<" -> string.utf_codepoint(0x21A2)
    // leftwards two headed arrow (↞):
    "<<-" -> string.utf_codepoint(0x219E)
    // left right arrow (↔):
    "<->" -> string.utf_codepoint(0x2194)
    // left right double arrow (⇔):
    "<=>" -> string.utf_codepoint(0x21D4)
    // long left right double arrow (⟺):
    "<==>" -> string.utf_codepoint(0x27FA)
    // long left right arrow (⟷):
    "<-->" -> string.utf_codepoint(0x27F7)
    // asterisk operator (∗):
    "*" -> string.utf_codepoint(0x2217)
    // double vertical line (‖):
    "||" -> string.utf_codepoint(0x2016)
    // left white square bracker (⟦):
    "[|" -> string.utf_codepoint(0x27E6)
    // right white square bracker (⟧):
    "|]" -> string.utf_codepoint(0x27E7)
    // colon equals (≔):
    ":=" -> string.utf_codepoint(0x2254)
    // double colon equals (⩴):
    "::=" -> string.utf_codepoint(0x2A74)
    // horizontal ellipsis (…):
    "..." -> string.utf_codepoint(0x2026)
    // equals colon (≕):
    "=:" -> string.utf_codepoint(0x2255)
    // not equal to (≠):
    "!=" -> string.utf_codepoint(0x2260)
    // much greater than (≫):
    ">>" -> string.utf_codepoint(0x226B)
    // greater than or equal to (≥):
    ">=" -> string.utf_codepoint(0x2265)
    // very much greater than (⋙):
    ">>>" -> string.utf_codepoint(0x22D9)
    // much less than (≪):
    "<<" -> string.utf_codepoint(0x226A)
    // less than or equal to (≤):
    "<=" -> string.utf_codepoint(0x2264)
    // very much less than (⋘):
    "<<<" -> string.utf_codepoint(0x22D8)
    // minus sign (−):
    "-" -> string.utf_codepoint(0x2212)
    // tilde operator (∼):
    "~" -> string.utf_codepoint(0x223C)
    // prime (′):
    "'" -> string.utf_codepoint(0x2032)
    // double pime (″):
    "''" -> string.utf_codepoint(0x2033)
    // triple prime (‴):
    "'''" -> string.utf_codepoint(0x2034)
    // quadruple prime (⁗):
    "''''" -> string.utf_codepoint(0x2057)
    _ -> Error(Nil)
  }
}

/// Converts a `UtfCodepoint` to a Typst math mode shorthand `String`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(arrow) = string.utf_codepoint(0x2192)  // '→'
///
/// assert Ok("->") == typst.math_shorthand_from_codepoint(arrow)
/// ```
///
pub fn math_shorthand_from_codepoint(
  codepoint: UtfCodepoint,
) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    // rightwards arrow (→):
    0x2192 -> Ok("->")
    // rightwards arrow from bar (↦):
    0x21A6 -> Ok("|->")
    // rightwards double arrow (⇒):
    0x21D2 -> Ok("=>")
    // rightwards double arrow from bar (⤇):
    0x2907 -> Ok("|=>")
    // long rightwards double arrow (⟹):
    0x27F9 -> Ok("==>")
    // long rightwards arrow (⟶):
    0x27F6 -> Ok("-->")
    // long rightwards squiggle arrow (⟿):
    0x27FF -> Ok("~~>")
    // rightwards squiggle arrow (⇝):
    0x21DD -> Ok("~>")
    // rightwards arrow with tail (↣):
    0x21A3 -> Ok(">->")
    // rightwards two headed arrow (↠):
    0x21A0 -> Ok("->>")
    // leftwards arrow (←):
    0x2190 -> Ok("<-")
    // leftwards long double arrow (⟸):
    0x27F8 -> Ok("<==")
    // long leftwards arrow (⟵):
    0x27F5 -> Ok("<--")
    // long leftwards squiggle arrow (⬳):
    0x2B33 -> Ok("<~~")
    // leftwards squiggle arrow (⇜):
    0x21DC -> Ok("<~")
    // leftwards arrow with tail (↢):
    0x21A2 -> Ok("<-<")
    // leftwards two headed arrow (↞):
    0x219E -> Ok("<<-")
    // left right arrow (↔):
    0x2194 -> Ok("<->")
    // left right double arrow (⇔):
    0x21D4 -> Ok("<=>")
    // long left right double arrow (⟺):
    0x27FA -> Ok("<==>")
    // long left right arrow (⟷):
    0x27F7 -> Ok("<-->")
    // asterisk operator (∗):
    0x2217 -> Ok("*")
    // double vertical line (‖):
    0x2016 -> Ok("||")
    // left white square bracker (⟦):
    0x27E6 -> Ok("[|")
    // right white square bracker (⟧):
    0x27E7 -> Ok("|]")
    // colon equals (≔):
    0x2254 -> Ok(":=")
    // double colon equals (⩴):
    0x2A74 -> Ok("::=")
    // horizontal ellipsis (…):
    0x2026 -> Ok("...")
    // equals colon (≕):
    0x2255 -> Ok("=:")
    // not equal to (≠):
    0x2260 -> Ok("!=")
    // much greater than (≫):
    0x226B -> Ok(">>")
    // greater than or equal to (≥):
    0x2265 -> Ok(">=")
    // very much greater than (⋙):
    0x22D9 -> Ok(">>>")
    // much less than (≪):
    0x226A -> Ok("<<")
    // less than or equal to (≤):
    0x2264 -> Ok("<=")
    // very much less than (⋘):
    0x22D8 -> Ok("<<<")
    // minus sign (−):
    0x2212 -> Ok("-")
    // tilde operator (∼):
    0x223C -> Ok("~")
    // prime (′):
    0x2032 -> Ok("'")
    // double pime (″):
    0x2033 -> Ok("''")
    // triple prime (‴):
    0x2034 -> Ok("'''")
    // quadruple prime (⁗):
    0x2057 -> Ok("''''")
    _ -> Error(Nil)
  }
}

/// Converts a `UtfCodepoint` to a Typst math alphanumeric symbol:
/// - [Math Styles](https://typst.app/docs/reference/math/styles)
/// - [Math Variants](https://typst.app/docs/reference/math/variants)
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(symtable) = typst.make_symtable()
///
/// assert Ok(["upright(C)"])
///   == string.utf_codepoint(0x0043)
///   |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
///
/// assert Ok(["C"])
///   == string.utf_codepoint(0x1D436)
///   |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
///
/// assert Error(Nil)
///   == string.utf_codepoint(0x1D53A)
///   |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
///
/// assert Ok(["bb(C)"])
///   == string.utf_codepoint(0x2102)
///   |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
///
/// assert Ok(["bold(Gamma)"])
///   == string.utf_codepoint(0x1D6AA)
///   |> result.try(typst.math_alphanum_from_codepoint(_, symtable))
/// ```
///
pub fn math_alphanum_from_codepoint(
  codepoint: UtfCodepoint,
  table table: Table,
) -> Result(List(String), Nil) {
  use alphanum <- result.try(math_alphanum.from_codepoint(codepoint))

  let notations = case dict.get(table.from_codepoint, alphanum.letter) {
    Ok(notations) -> notations
    Error(_) -> [string.from_utf_codepoints([alphanum.letter])]
  }

  // NOTE: "italic" default for roman letters and greek _lowercase_ letters
  let math_styles = case alphanum {
    math_alphanum.LatinSerif(_, Italic, Regular) -> []
    math_alphanum.DigitSerif(_, Regular) -> []
    math_alphanum.LatinSerif(_, Italic, Bold) -> ["bold"]
    math_alphanum.DigitSerif(_, Bold) -> ["bold"]
    math_alphanum.LatinSerif(_, Upright, Regular) -> ["upright"]
    math_alphanum.LatinSerif(_, Upright, Bold) -> ["upright", "bold"]
    math_alphanum.LatinScript(_, Regular) -> ["cal"]
    math_alphanum.LatinScript(_, Bold) -> ["cal", "bold"]
    math_alphanum.LatinFraktur(_, Regular) -> ["frak"]
    math_alphanum.LatinFraktur(_, Bold) -> ["frak", "bold"]
    math_alphanum.LatinSans(_, Italic, Regular) -> ["sans"]
    math_alphanum.DigitSans(_, Regular) -> ["sans"]
    math_alphanum.LatinSans(_, Italic, Bold) -> ["sans", "bold"]
    math_alphanum.DigitSans(_, Bold) -> ["sans", "bold"]
    math_alphanum.LatinSans(_, Upright, Regular) -> ["upright", "sans"]
    math_alphanum.LatinSans(_, Upright, Bold) -> ["upright", "sans", "bold"]
    math_alphanum.LatinMono(_) -> ["mono"]
    math_alphanum.DigitMono(_) -> ["mono"]
    math_alphanum.LatinDoubleStruck(_) -> ["bb"]
    math_alphanum.DigitDoubleStruck(_) -> ["bb"]
    math_alphanum.GreekDoubleStruck(_) -> ["bb"]
    math_alphanum.GreekSerif(letter, slope, Regular) ->
      greek_slope(letter, slope, [])
    math_alphanum.GreekSerif(letter, slope, Bold) ->
      greek_slope(letter, slope, ["bold"])
    math_alphanum.GreekSansBold(letter:, slope:) ->
      greek_slope(letter, slope, ["sans"])
    math_alphanum.Hebrew(_) -> []
  }

  Ok(list.map(notations, apply_math_styles(_, math_styles)))
}

fn greek_slope(
  letter: UtfCodepoint,
  slope: math_alphanum.Slope,
  styles: List(String),
) -> List(String) {
  let str = string.from_utf_codepoints([letter])
  let is_lowercase =
    str == string.lowercase(str) && str != string.uppercase(str)
  case slope {
    Italic if is_lowercase -> styles
    Italic -> ["italic", ..styles]
    Upright if is_lowercase -> ["upright", ..styles]
    Upright -> styles
  }
}

fn apply_math_styles(string: String, styles: List(String)) -> String {
  case styles {
    [] -> string
    [style, ..rest] -> apply_math_styles(style <> "(" <> string <> ")", rest)
  }
}

/// Converts a `UtfCodepoint` to a `List` of Typst notations `String`.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(tables) = typst.make_tables()
///
/// assert Ok(["#emoji.star.glow"])
///   == string.utf_codepoint(0x1F31F)
///   |> result.map(typst.notations_from_codepoint(_, tables))
///
/// assert Ok(["#sym.star.op"])
///   == string.utf_codepoint(0x22C6)
///   |> result.map(typst.notations_from_codepoint(_, tables))
///
/// assert Ok(["#sym.dash.en", "--"])
///   == string.utf_codepoint(0x2013)
///   |> result.map(typst.notations_from_codepoint(_, tables))
///
/// assert Ok(["#sym.arrow.r", "$ -> $"])
///   == string.utf_codepoint(0x2192)
///   |> result.map(typst.notations_from_codepoint(_, tables))
///
/// assert Ok(["#sym.Gamma", "$ Gamma $"])
///   == string.utf_codepoint(0x0393)
///   |> result.map(typst.notations_from_codepoint(_, tables))
///
/// assert Ok(["$ bold(Gamma) $"])
///   == string.utf_codepoint(0x1D6AA)
///   |> result.map(typst.notations_from_codepoint(_, tables))
/// ```
///
pub fn notations_from_codepoint(
  codepoint: UtfCodepoint,
  tables tables: Tables,
) -> List(String) {
  let sym_notations =
    result.unwrap(dict.get(tables.symtable.from_codepoint, codepoint), or: [])
    |> list.map(fn(notation) { "#sym." <> notation })
  let emoji_notations =
    result.unwrap(dict.get(tables.emojitable.from_codepoint, codepoint), or: [])
    |> list.map(fn(notation) { "#emoji." <> notation })
  let markup_shorthand =
    markup_shorthand_from_codepoint(codepoint)
    |> result.map(list.wrap)
    |> result.unwrap([])
  let math_shorthand =
    math_shorthand_from_codepoint(codepoint)
    |> result.map(list.wrap)
    |> result.unwrap([])
    |> list.map(display_math)
  let math_alphanum_notations =
    math_alphanum_from_codepoint(codepoint, tables.symtable)
    |> result.unwrap([])
    |> list.map(display_math)
  sym_notations
  |> list.append(emoji_notations)
  |> list.append(markup_shorthand)
  |> list.append(math_shorthand)
  |> list.append(math_alphanum_notations)
}

/// Converts a Typst codex name `String` to a `UtfCodepoint`,
/// only handles names listed in these two modules:
/// [sym](https://typst.app/docs/reference/symbols/sym/),
/// and [emoji](https://typst.app/docs/reference/symbols/emoji/).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(tables) = typst.make_tables()
///
/// assert Ok(string.to_utf_codepoints("\u{22C6}"))
///   == typst.notation_to_codepoints("#sym.star.op", tables)
///
/// assert Ok(string.to_utf_codepoints("\u{2B50}"))
///   == typst.notation_to_codepoints("#emoji.star", tables)
///
/// assert Error(Nil) == typst.notation_to_codepoints("emoji.star", tables)
///
/// assert Error(Nil) == typst.notation_to_codepoints("#emoji.staaar", tables)
/// ```
///
pub fn notation_to_codepoints(
  notation: String,
  tables tables: Tables,
) -> Result(List(UtfCodepoint), Nil) {
  case notation {
    "#sym." <> name -> dict.get(tables.symtable.to_codepoints, name)
    "#emoji." <> name -> dict.get(tables.emojitable.to_codepoints, name)
    _ -> Error(Nil)
  }
}

/// Converts a Typst codex name `String` to the refered `String`,
/// only handles names listed in these two modules:
/// [sym](https://typst.app/docs/reference/symbols/sym/),
/// and [emoji](https://typst.app/docs/reference/symbols/emoji/).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(tables) = typst.make_tables()
///
/// assert Ok("\u{22C6}") == typst.notation_to_string("#sym.star.op", tables)
///
/// assert Ok("\u{2B50}") == typst.notation_to_string("#emoji.star", tables)
///
/// assert Error(Nil) == typst.notation_to_string("emoji.star", tables)
///
/// assert Error(Nil) == typst.notation_to_string("#emoji.staaar", tables)
/// ```
///
pub fn notation_to_string(
  notation: String,
  tables tables: Tables,
) -> Result(String, Nil) {
  notation_to_codepoints(notation, tables)
  |> result.map(string.from_utf_codepoints)
}

fn display_math(string: String) -> String {
  "$ " <> string <> " $"
}
