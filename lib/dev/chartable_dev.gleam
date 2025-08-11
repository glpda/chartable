import chartable/internal/typst_codegen
import chartable/internal/unicode_codegen
import simplifile

pub fn main() {
  let assert Ok(names) = simplifile.read("data/unicode/names.txt")
  let names = unicode_codegen.parse_unidata(names)
  let assert Ok(template) = simplifile.read("codegen_templates/name_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/name_map.mjs",
      contents: unicode_codegen.make_name_map(names:, template:),
    )

  let assert Ok(template) =
    simplifile.read("codegen_templates/notation_map.mjs")
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/sym.txt"
  let assert Ok(sym) = simplifile.read("data/typst/sym.txt")
  let assert Ok(codex) = typst_codegen.parse_codex(sym)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/symbol_map.mjs",
      contents: typst_codegen.make_map(codex:, template:, data_source:),
    )
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/emoji.txt"
  let assert Ok(emoji) = simplifile.read("data/typst/emoji.txt")
  let assert Ok(codex) = typst_codegen.parse_codex(emoji)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/emoji_map.mjs",
      contents: typst_codegen.make_map(codex:, template:, data_source:),
    )
}
