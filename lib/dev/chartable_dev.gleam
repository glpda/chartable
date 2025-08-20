import codegen/html
import codegen/typst
import codegen/unicode
import simplifile

pub fn main() {
  let assert Ok(txt) = simplifile.read("data/unicode/names.txt")
  let assert Ok(names) = unicode.parse_names(txt)
  let assert Ok(template) = simplifile.read("codegen_templates/name_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/name_map.mjs",
      contents: unicode.make_name_map(names:, template:),
    )

  let assert Ok(template) =
    simplifile.read("codegen_templates/notation_map.mjs")
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/sym.txt"
  let assert Ok(sym) = simplifile.read("data/typst/sym.txt")
  let assert Ok(codex) = typst.parse_codex(sym)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/symbol_map.mjs",
      contents: typst.make_map(codex:, template:, data_source:),
    )
  let data_source =
    "https://github.com/typst/codex/blob/main/src/modules/emoji.txt"
  let assert Ok(emoji) = simplifile.read("data/typst/emoji.txt")
  let assert Ok(codex) = typst.parse_codex(emoji)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/typst/emoji_map.mjs",
      contents: typst.make_map(codex:, template:, data_source:),
    )
  let data_source = "https://html.spec.whatwg.org/entities.json"
  let assert Ok(json) = simplifile.read("data/html/entities.json")
  let assert Ok(entities) = html.parse_entities_json(json)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/html/entity_map.mjs",
      contents: html.make_map(entities:, template:, data_source:),
    )
}
