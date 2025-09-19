import chartable/internal
import codegen/notation_table.{type NotationTable, NotationTable}
import gleam/dict
import gleam/result
import gleam/string
import splitter

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
    pair: Pair,
  )
}

/// Helper type providing labels for key-value pairs to not mix grapheme and
/// notation `String`s.
type Pair {
  Pair(grapheme: String, notation: String)
  None
}

pub fn make_map(
  codex table: NotationTable,
  template template: String,
  data_source data_source: String,
) -> String {
  notation_table.make_javascript_map(table:, template:, data_source:)
}

fn next_line(state state: ParserState, rest txt: String) -> ParserState {
  ParserState(..state, txt:, line: state.line + 1, pair: None)
}

pub fn parse_codex(txt: String) -> Result(NotationTable, ParserError) {
  let table = NotationTable(dict.new(), dict.new())
  let line_ends = splitter.new(["\n", "\r\n"])
  let comments = splitter.new(["//", "@"])
  let space = splitter.new([" "])

  let initialize_parser =
    ParserState(line: 0, txt:, prefix: "", submodule: "", pair: None)
  use state <- parse_codex_loop(input: initialize_parser, output: table)
  let #(line, _, rest) = splitter.split(line_ends, state.txt)
  let line = splitter.split_before(comments, line).0 |> string.trim
  case line {
    "" -> Ok(next_line(state:, rest:))
    "}" <> _ if state.submodule != "" ->
      Ok(ParserState(..next_line(state:, rest:), submodule: ""))
    "}" <> _ -> Error(SubmoduleNotOpen(state.line))
    line -> {
      let #(key, _, symbol) = splitter.split(space, line)
      case key, symbol {
        "", _ -> Ok(next_line(state:, rest:))
        "." <> suffix, symbol ->
          parse_grapheme(symbol)
          |> result.replace_error(InvalidCodepoints(state.line))
          |> result.map(fn(grapheme) {
            ParserState(
              ..next_line(state:, rest:),
              pair: Pair(grapheme:, notation: suffix),
            )
          })
        prefix, "" -> Ok(ParserState(..next_line(state:, rest:), prefix:))
        submodule, "{" ->
          Ok(ParserState(..next_line(state:, rest:), prefix: "", submodule:))
        prefix, symbol ->
          parse_grapheme(symbol)
          |> result.replace_error(InvalidCodepoints(state.line))
          |> result.map(fn(grapheme) {
            ParserState(
              ..next_line(state:, rest:),
              prefix:,
              pair: Pair(grapheme:, notation: ""),
            )
          })
      }
    }
  }
}

fn parse_grapheme(str: String) -> Result(String, Nil) {
  parse_grapheme_loop(str, "")
}

fn parse_grapheme_loop(str: String, acc: String) -> Result(String, Nil) {
  case str {
    "" ->
      case acc {
        "" -> Error(Nil)
        _ -> Ok(acc)
      }
    "\\u{" <> rest -> {
      use #(hex_code, rest) <- result.try(string.split_once(rest, on: "}"))
      use codepoint <- result.try(internal.parse_utf(hex_code))
      parse_grapheme_loop(rest, acc <> string.from_utf_codepoints([codepoint]))
    }
    string -> {
      use #(grapheme, rest) <- result.try(string.pop_grapheme(string))
      parse_grapheme_loop(rest, acc <> grapheme)
    }
  }
}

fn parse_codex_loop(
  input state: ParserState,
  output table: NotationTable,
  with parser: fn(ParserState) -> Result(ParserState, ParserError),
) -> Result(NotationTable, ParserError) {
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
            None -> parse_codex_loop(input: state, output: table, with: parser)
            Pair(grapheme:, notation: suffix) ->
              case make_identifier(state.submodule, state.prefix, suffix) {
                Error(_) -> Error(InvalidIdentifier(state.line))
                Ok(notation) -> {
                  case table.notation_to_grapheme |> dict.has_key(notation) {
                    True -> Error(DuplicateIdentifier(state.line))
                    False ->
                      parse_codex_loop(
                        input: state,
                        output: notation_table.update(
                          table,
                          grapheme:,
                          notation:,
                        ),
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
