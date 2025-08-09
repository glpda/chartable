import chartable/internal/typst_codegen
import chartable/internal/unicode_codegen
import simplifile

pub fn main() {
  let assert Ok(names) = simplifile.read("data/unicode/names.txt")
  let assert Ok(codegen_src) = simplifile.read("data/unicode/name_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/name_map.mjs",
      contents: unicode_codegen.make_name_map(names:, codegen_src:),
    )

  let assert Ok(codegen_source) = simplifile.read("data/typst/codex_map.mjs")
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/sym.txt"
  let assert Ok(codex) = simplifile.read("data/typst/sym.txt")
  let assert Ok(table) = typst_codegen.parse_codex(codex)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/symbol_map.mjs",
      contents: typst_codegen.make_map(table:, codegen_source:, data_source:),
    )
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/emoji.txt"
  let assert Ok(codex) = simplifile.read("data/typst/emoji.txt")
  let assert Ok(table) = typst_codegen.parse_codex(codex)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/emoji_map.mjs",
      contents: typst_codegen.make_map(table:, codegen_source:, data_source:),
    )
}
