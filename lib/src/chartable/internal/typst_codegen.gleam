import chartable/internal
import chartable/internal/notation_table.{type NotationTable, NotationTable}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
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

pub type ParserState {
  ParserState(
    line: Int,
    txt: String,
    prefix: String,
    submodule: String,
    pair: Option(#(List(UtfCodepoint), String)),
  )
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
  let #(line, _, _) = splitter.split(comments, line)
  let line = string.trim(line)
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
        _ -> Ok(list.reverse(acc))
      }
    "\\u{" <> rest -> {
      use #(hex_code, rest) <- result.try(string.split_once(rest, on: "}"))
      use codepoint <- result.try(internal.parse_codepoint(hex_code))
      parse_codepoints(rest, [codepoint, ..acc])
    }
    string -> {
      use #(grapheme, rest) <- result.try(string.pop_grapheme(string))
      let acc = list.append(string.to_utf_codepoints(grapheme), acc)
      parse_codepoints(rest, acc)
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
            Some(#(codepoints, suffix)) ->
              case make_identifier(state.submodule, state.prefix, suffix) {
                Error(_) -> Error(InvalidIdentifier(state.line))
                Ok(identifier) -> {
                  case
                    table.notation_to_codepoints |> dict.has_key(identifier)
                  {
                    True -> Error(DuplicateIdentifier(state.line))
                    False ->
                      parse_codex_loop(
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

fn update_table(
  table: NotationTable,
  codepoints: List(UtfCodepoint),
  notation: String,
) {
  let codepoint_to_notations = case codepoints {
    [codepoint] ->
      dict.upsert(codepoint, in: table.codepoint_to_notations, with: fn(option) {
        case option {
          None -> [notation]
          Some(list) -> [notation, ..list]
        }
      })
    _ -> table.codepoint_to_notations
  }

  let notation_to_codepoints =
    dict.insert(codepoints, into: table.notation_to_codepoints, for: notation)
  NotationTable(codepoint_to_notations:, notation_to_codepoints:)
}
