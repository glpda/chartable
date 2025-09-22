import birdie
import chartable/html
import chartable/internal
import chartable/typst
import chartable/unicode
import codegen/html as html_codegen
import codegen/latex
import codegen/notation_table
import codegen/typst as typst_codegen
import codegen/unicode as unicode_codegen
import gleam/dict
import gleam/string
import simplifile

// =============================================================================
// BEGIN Unicode Tests

pub fn unicode_name_test() {
  let assert Ok(txt) = simplifile.read("data/unicode/names.txt")
  let assert Ok(names) = unicode_codegen.parse_names(txt)

  unicode_codegen.assert_match_range_records(names, fn(cp, name) {
    assert name != ""
    let hex = internal.codepoint_to_hex(cp)
    let name = string.replace(in: name, each: "*", with: hex)
    unicode.name_from_codepoint(cp) == Ok(name)
  })
}

pub fn unicode_blocks_test() {
  let assert Ok(txt) = simplifile.read("data/unicode/blocks.txt")
  let assert Ok(blocks) = unicode_codegen.parse_blocks(txt)

  unicode_codegen.assert_match_range_records(blocks, fn(cp, block_name) {
    let assert Ok(block) = unicode.block_from_codepoint(cp)
    block.name == block_name
  })

  unicode_codegen.range_records_to_string(blocks, fn(block_name) { block_name })
  |> birdie.snap(title: "Unicode Blocks")
}

pub fn unicode_category_test() {
  let assert Ok(txt) = simplifile.read("data/unicode/categories.txt")
  let assert Ok(categories) = unicode_codegen.parse_categories(txt)

  unicode_codegen.assert_match_range_records(categories, fn(cp, category) {
    unicode.category_from_codepoint(cp) == category
  })
}

// END

// =============================================================================
// BEGIN Typst Notation Tests

pub fn typst_symbol_test() {
  let assert Ok(sym) = simplifile.read("data/typst/sym.txt")
  let assert Ok(table) = typst_codegen.parse_codex(sym)

  notation_table.assert_consistency(table)

  dict.each(table.notation_to_grapheme, fn(notation, grapheme) {
    assert typst.notation_to_grapheme("#sym." <> notation) == Ok(grapheme)
  })

  notation_table.to_string(table)
  |> birdie.snap(title: "Typst symbol notations from codepoints")
}

pub fn typst_emoji_test() {
  let assert Ok(emoji) = simplifile.read("data/typst/emoji.txt")
  let assert Ok(table) = typst_codegen.parse_codex(emoji)

  notation_table.assert_consistency(table)

  dict.each(table.notation_to_grapheme, fn(notation, grapheme) {
    assert typst.notation_to_grapheme("#emoji." <> notation) == Ok(grapheme)
  })

  notation_table.to_string(table)
  |> birdie.snap(title: "Typst emoji notations from codepoints")
}

// END

// =============================================================================
// BEGIN HTML Notation Tests

pub fn html_entity_test() {
  let assert Ok(json) = simplifile.read("data/html/entities.json")
  let assert Ok(table) = html_codegen.parse_entities_json(json)

  notation_table.assert_consistency(table)

  dict.each(table.notation_to_grapheme, fn(notation, grapheme) {
    assert html.character_reference_to_grapheme("&" <> notation <> ";")
      == Ok(grapheme)
  })

  notation_table.to_string(table)
  |> birdie.snap(title: "HTML entities from codepoints")
}

// END

// =============================================================================
// BEGIN LaTeX Notation Tests

pub fn latex_symbols_test() {
  let assert Ok(tex) = simplifile.read("data/latex/unicode-math.tex")
  let assert Ok(math_symbols) = latex.parse_math_symbols(tex)

  latex.math_symbols_to_notation_table(math_symbols)
  |> notation_table.to_string
  |> birdie.snap(title: "LaTeX3 Unicode Math from codepoints")
}

pub fn lucr_unimath_test() {
  let assert Ok(txt) = simplifile.read("data/latex/lucr-unimath.txt")
  let assert Ok(lucr_unimath) = latex.parse_lucr_unimath(txt)

  latex.lucr_unimath_to_notation_table(lucr_unimath)
  |> notation_table.to_string
  |> birdie.snap(title: "LUCR Unicode Math from codepoints")
}
// END
