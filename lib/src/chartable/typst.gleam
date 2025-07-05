//// Converts between Unicode code points and [typst notations](https://typst.app/docs/reference)

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
pub type FromCodepoint =
  Dict(UtfCodepoint, List(String))

/// Maps typst codex identifiers to code points.
pub type ToCodepoints =
  Dict(String, List(UtfCodepoint))

/// Maps code points to typst codex identifiers and the other way around.
pub type Table {
  Table(from_codepoint: FromCodepoint, to_codepoints: ToCodepoints)
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
