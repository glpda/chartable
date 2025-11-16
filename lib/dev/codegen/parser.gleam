import gleam/list
import gleam/result
import gleam/string
import splitter

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
  // initial status:
  init state: state,
  // comment split position:
  comment comment: SplitPosition,
  // line/record parser:
  parser parser: fn(String, state) -> Result(state, String),
  // final state processing:
  reducer reducer: fn(state) -> Result(output, String),
) -> Result(output, ParserError) {
  let line_end = splitter.new(["\n", "\r\n"])
  case comment {
    Anywhere(comment_markers) -> {
      let comment_splitter = splitter.new(comment_markers)
      use txt, state <- loop(txt:, line: 0, state:, reducer:)
      let #(line, _, rest) = splitter.split(line_end, txt)
      let line = splitter.split_before(comment_splitter, line).0 |> string.trim
      case line {
        "" -> #(Ok(state), rest)
        _ -> #(parser(line, state), rest)
      }
    }
    LineStart(comment_markers) -> {
      use txt, state <- loop(txt:, line: 0, state:, reducer:)
      let #(line, _, rest) = splitter.split(line_end, txt)
      case list.any(comment_markers, string.starts_with(line, _)) {
        True -> #(Ok(state), rest)
        _ if line == "" -> #(Ok(state), rest)
        False -> #(parser(line, state), rest)
      }
    }
  }
}

fn loop(
  // remaining txt lines/records:
  txt txt: String,
  // number of lines/records parsed:
  line line: Int,
  // current status:
  state state: state,
  // fn(txt, state) -> #(Result(state, "error message"), rest)
  parser parser: fn(String, state) -> #(Result(state, String), String),
  reducer reducer: fn(state) -> Result(output, String),
) -> Result(output, ParserError) {
  case txt {
    "" -> reducer(state) |> result.map_error(ParserError(_, line:))
    _ ->
      case parser(txt, state) {
        #(Ok(state), rest) ->
          loop(txt: rest, line: line + 1, state:, parser:, reducer:)
        #(Error(error), _) -> Error(ParserError(line:, error:))
      }
  }
}
