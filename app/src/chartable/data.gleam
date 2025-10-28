import chartable/unicode
import chartable/unicode/codepoint.{type Codepoint}
import chartable/unicode/script.{type Script}
import gleam/list

pub type Data {
  Data(
    blocks: List(unicode.Block),
    scripts: List(Script),
    default_block: unicode.Block,
    default_script: Script,
    default_codepoint: Codepoint,
  )
}

pub fn init() {
  let blocks = unicode.blocks()
  let scripts = script.list()
  let assert Ok(default_block) = list.first(blocks)
  let assert Ok(default_script) = script.from_name("latin")
  let assert Ok(default_codepoint) = codepoint.from_int(0x41)
  Data(blocks:, scripts:, default_block:, default_script:, default_codepoint:)
}
