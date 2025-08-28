import birdie
import chartable/html
import chartable/internal
import chartable/typst
import chartable/unicode
import codegen/html as html_codegen
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

  unicode_codegen.assert_match_unidata(names, fn(cp, name) {
    assert name != ""
    let hex = internal.int_to_hex(cp)
    let name = string.replace(in: name, each: "*", with: hex)
    unicode.name_from_int(cp) == Ok(name)
  })
}

pub fn unicode_blocks_test() {
  let assert Ok(txt) = simplifile.read("data/unicode/blocks.txt")
  let assert Ok(blocks) = unicode_codegen.parse_blocks(txt)

  unicode_codegen.assert_match_unidata(blocks, fn(cp, block) {
    unicode.block_from_int(cp) == Ok(block)
  })
}

pub fn unicode_category_test() {
  let assert Ok(txt) = simplifile.read("data/unicode/categories.txt")
  let assert Ok(categories) = unicode_codegen.parse_categories(txt)

  unicode_codegen.assert_match_unidata(categories, fn(cp, category) {
    unicode.category_from_int(cp) == category
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
