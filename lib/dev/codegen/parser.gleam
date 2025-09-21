import gleam/list
import gleam/string
import splitter

type ParserState {
  // ParserState(line: Int, txt: String, status: status)
  ParserState(line: Int, txt: String)
}

pub type ParserError {
  ParserError(line: Int, error: String)
}

pub type SplitPosition {
  Anywhere(List(String))
  LineStart(List(String))
}

pub fn parse_lines(
  // input txt lines/records:
  txt txt: String,
  // comment split position:
  comment comment: SplitPosition,
  // line/record parser (return `Error("")` for empty lines):
  parser parser: fn(String) -> Result(record, String),
  // process the resulting list of records (in reverse order):
  reducer reducer: fn(List(record)) -> output,
) -> Result(output, ParserError) {
  let line_end = splitter.new(["\n"])
  let parser_state = ParserState(line: 0, txt:)

  case comment {
    Anywhere(comment_markers) -> {
      let comment_splitter = splitter.new(comment_markers)
      use txt <- parser_loop(input: parser_state, acc: [], reducer:)
      let #(line, _, rest) = splitter.split(line_end, txt)
      let line = splitter.split_before(comment_splitter, line).0 |> string.trim
      case line {
        "" -> #(Error(""), rest)
        _ -> #(parser(line), rest)
      }
    }
    LineStart(comment_markers) -> {
      use txt <- parser_loop(input: parser_state, acc: [], reducer:)
      let #(line, _, rest) = splitter.split(line_end, txt)
      case list.any(comment_markers, string.starts_with(line, _)) {
        True -> #(Error(""), rest)
        _ if line == "" -> #(Error(""), rest)
        False -> #(parser(line), rest)
      }
    }
  }
}

fn parser_loop(
  input state: ParserState,
  // Records accumulator
  acc records: List(record),
  // Returns `#(Result(record, "error message"), rest)`,
  // empty error messages are ignored
  parser parser: fn(String) -> #(Result(record, String), String),
  reducer reducer: fn(List(record)) -> output,
) -> Result(output, ParserError) {
  case state.txt {
    "" -> Ok(reducer(records))
    txt ->
      case parser(txt) {
        #(Ok(record), rest) -> {
          let acc = [record, ..records]
          let state = ParserState(line: state.line + 1, txt: rest)
          parser_loop(state, acc:, parser:, reducer:)
        }
        #(Error(""), rest) -> {
          let state = ParserState(line: state.line + 1, txt: rest)
          parser_loop(state, acc: records, parser:, reducer:)
        }
        #(Error(error), _) -> Error(ParserError(line: state.line, error:))
      }
  }
}
