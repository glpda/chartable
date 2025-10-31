import chartable/data.{type Data}
import chartable/unicode
import chartable/unicode/codepoint.{type Codepoint}
import chartable/unicode/script.{type Script as UnicodeScript}

import gleam/result
import gleam/string
import gleam/uri.{type Uri}

pub type Route {
  Block(unicode.Block, codepoint: Codepoint)
  Script(UnicodeScript, codepoint: Codepoint)
}

pub fn block_path(block: unicode.Block) -> String {
  "/block/" <> string.lowercase(block.name) |> string.replace(" ", with: "-")
}

pub fn script_path(script: UnicodeScript) -> String {
  "/script/" <> string.lowercase(script.to_short_name(script))
}

pub fn codepoint_path(codepoint: Codepoint, route: Route) {
  let route = case route {
    Block(block, ..) -> Block(block, codepoint:)
    Script(script, ..) -> Script(script, codepoint:)
  }
  to_path(route)
}

pub fn to_path(route: Route) -> String {
  let base_path = case route {
    Block(block, ..) -> block_path(block)
    Script(script, ..) -> script_path(script)
  }
  let hex = codepoint.to_hex(route.codepoint)
  base_path <> "/" <> hex
}

pub fn from_uri(uri: Uri, data: Data) -> Route {
  let parse_codepoint = fn(rest) {
    case rest {
      [hex] -> codepoint.parse(hex) |> result.unwrap(data.default_codepoint)
      _ -> data.default_codepoint
    }
  }
  case uri.path_segments(uri.path) {
    ["block", block, ..rest] -> {
      let block =
        unicode.block_from_name(block) |> result.unwrap(data.default_block)
      let codepoint = parse_codepoint(rest)
      Block(block, codepoint)
    }
    ["script", script, ..rest] -> {
      let script =
        script.from_name(script) |> result.unwrap(data.default_script)
      let codepoint = parse_codepoint(rest)
      Script(script, codepoint)
    }
    _ -> {
      Block(data.default_block, data.default_codepoint)
    }
  }
}
