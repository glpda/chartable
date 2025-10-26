import codegen/html
import codegen/latex
import codegen/typst
import codegen/unicode
import simplifile

pub fn main() {
  let assert Ok(txt) =
    simplifile.read("data/unicode/property-value-aliases.txt")
  let assert Ok(property_value_aliases) =
    unicode.parse_property_value_aliases(txt)

  let assert Ok(txt) = simplifile.read("data/unicode/names.txt")
  let assert Ok(names) = unicode.parse_names(txt)
  let assert Ok(template) = simplifile.read("codegen_templates/name_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/name_map.mjs",
      contents: unicode.make_name_map(names:, template:),
    )
  let assert Ok(txt) = simplifile.read("data/unicode/blocks.txt")
  let assert Ok(blocks) = unicode.parse_blocks(txt)
  let assert Ok(template) = simplifile.read("codegen_templates/block_map.mjs")
  let block_map =
    unicode.make_block_map(property_value_aliases:, blocks:, template:)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/block_map.mjs",
      contents: block_map,
    )
  let assert Ok(txt) = simplifile.read("data/unicode/scripts.txt")
  let assert Ok(scripts) = unicode.parse_scripts(txt:, property_value_aliases:)
  let assert Ok(template) = simplifile.read("codegen_templates/script_map.mjs")
  let script_map =
    unicode.make_script_map(property_value_aliases:, scripts:, template:)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/script_map.mjs",
      contents: script_map,
    )
  let assert Ok(txt) = simplifile.read("data/unicode/categories.txt")
  let assert Ok(categories) = unicode.parse_alternating_categories(txt)
  let assert Ok(template) =
    simplifile.read("codegen_templates/category_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/category_map.mjs",
      contents: unicode.make_category_map(categories:, template:),
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
  let assert Ok(template) =
    simplifile.read("codegen_templates/latex_math_map.mjs")
  let data_source = "https://mirrors.ctan.org/info/impatient/book.pdf"
  let assert Ok(txt) = simplifile.read("data/latex/tex-math.txt")
  let assert Ok(math_symbols) = latex.parse_texmath_symbols(txt:)
  let texmath_map =
    latex.javascript_math_map(math_symbols:, template:, data_source:)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/latex/texmath_map.mjs",
      contents: texmath_map,
    )
  let data_source =
    "https://github.com/latex3/unicode-math/blob/master/unicode-math-table.tex"
  let assert Ok(tex) = simplifile.read("data/latex/unicode-math.tex")
  let assert Ok(math_symbols) = latex.parse_unimath_symbols(tex:)
  let unimath_map =
    latex.javascript_math_map(math_symbols:, template:, data_source:)
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/latex/unimath_map.mjs",
      contents: unimath_map,
    )
}
