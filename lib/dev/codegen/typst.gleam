import chartable/unicode/codepoint
import codegen/notation_table.{type NotationTable}
import codegen/parser.{type ParserError}
import gleam/bool
import gleam/result
import gleam/string
import splitter

type ParserState {
  ParserState(prefix: String, module: String, table: NotationTable)
}

pub fn js_map(
  codex table: NotationTable,
  template template: String,
  data_source data_source: String,
) -> String {
  notation_table.js_map(table:, template:, data_source:)
}

pub fn parse_codex(txt: String) -> Result(NotationTable, ParserError) {
  let init = ParserState(prefix: "", module: "", table: notation_table.new())
  let comment = parser.After(["//", "@"])
  let space = splitter.new([" "])
  let reducer = fn(state: ParserState) {
    case state.module {
      "" -> Ok(state.table)
      _ -> Error("Submodule Not Closed")
    }
  }
  use line, state <- parser.parse_lines(txt:, init:, comment:, reducer:)
  use <- bool.guard(
    when: string.starts_with(line, "}"),
    return: case state.module {
      "" -> Error("Submodule Not Opened")
      _ -> Ok(ParserState(..state, module: ""))
    },
  )
  let #(key, _, symbol) = splitter.split(space, line)
  case key, symbol {
    "", _ -> Error("Invalid Key")
    ".", _ -> Error("Invalid Key")
    "." <> _, "" -> Error("Invalid Prefix")
    "." <> _, "{" -> Error("Invalid Submodule")
    prefix, "" -> Ok(ParserState(..state, prefix:))
    module, "{" ->
      case state.module {
        "" -> Ok(ParserState(..state, prefix: "", module:))
        _ -> Error("Submodule Not Closed")
      }
    key, symbol -> {
      use grapheme <- result.try(
        parse_grapheme(symbol)
        |> result.replace_error("Invalid Codepoints"),
      )
      use notation <- result.try(case state.module, state.prefix, key {
        _, "", "." <> _ -> Error("Invalid Prefix")
        "", prefix, "." <> suffix -> Ok(prefix <> "." <> suffix)
        module, prefix, "." <> suffix ->
          Ok(module <> "." <> prefix <> "." <> suffix)
        "", _, notation -> Ok(notation)
        module, _, notation -> Ok(module <> "." <> notation)
      })
      let table = notation_table.update(state.table, grapheme:, notation:)
      case key {
        "." <> _ -> Ok(ParserState(..state, table:))
        prefix -> Ok(ParserState(..state, prefix:, table:))
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
      use codepoint <- result.try(codepoint.parse_utf(hex_code))
      parse_grapheme_loop(rest, acc <> string.from_utf_codepoints([codepoint]))
    }
    "\\vs{" <> rest -> {
      use #(vs, rest) <- result.try(string.split_once(rest, on: "}"))
      use vs <- result.try(parse_variation_selector(vs))
      parse_grapheme_loop(rest, acc <> vs)
    }
    string -> {
      use #(grapheme, rest) <- result.try(string.pop_grapheme(string))
      parse_grapheme_loop(rest, acc <> grapheme)
    }
  }
}

fn parse_variation_selector(vs: String) -> Result(String, Nil) {
  case vs {
    "16" | "emoji" -> Ok("\u{FE0F}")
    "15" | "text" -> Ok("\u{FE0E}")
    "1" -> Ok("\u{FE00}")
    "2" -> Ok("\u{FE01}")
    "3" -> Ok("\u{FE02}")
    "4" -> Ok("\u{FE03}")
    "5" -> Ok("\u{FE04}")
    "6" -> Ok("\u{FE05}")
    "7" -> Ok("\u{FE06}")
    "8" -> Ok("\u{FE07}")
    "9" -> Ok("\u{FE08}")
    "10" -> Ok("\u{FE09}")
    "11" -> Ok("\u{FE0A}")
    "12" -> Ok("\u{FE0B}")
    "13" -> Ok("\u{FE0C}")
    "14" -> Ok("\u{FE0D}")
    _ -> Error(Nil)
  }
}
