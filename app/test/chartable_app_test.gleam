import chartable/data
import chartable/route
import chartable/unicode/codepoint

import gleam/uri.{Uri}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn route_test() {
  let data = data.init()
  let route_from_path = fn(path) {
    Uri(..uri.empty, path:) |> route.from_uri(data)
  }
  let assert Ok(star) = codepoint.from_int(0x2B50)

  assert route.block_path(data.default_block) == "/block/basic-latin"
  assert route.script_path(data.default_script) == "/script/latn"

  let block_path = "/block/basic-latin/0041"
  let route_block = route.Block(data.default_block, data.default_codepoint)
  assert route.to_path(route_block) == block_path
  assert route_from_path(block_path) == route_block
  assert route_from_path("/block/Basic Latin") == route_block
  assert route_from_path("/block/ascii") == route_block
  assert route_from_path("/") == route_block
  assert route.codepoint_path(star, route_block) == "/block/basic-latin/2B50"

  let script_path = "/script/latn/0041"
  let route_script = route.Script(data.default_script, data.default_codepoint)
  assert route.to_path(route_script) == script_path
  assert route_from_path(script_path) == route_script
  assert route_from_path("/script/Latin") == route_script
  assert route.codepoint_path(star, route_script) == "/script/latn/2B50"
}
