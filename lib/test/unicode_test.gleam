import chartable/unicode
import chartable/unicode/category
import chartable/unicode/script
import gleam/list
import gleam/result
import gleam/string

// =============================================================================
// BEGIN Unicode Name Tests

pub fn name_from_codepoint_test() {
  assert string.utf_codepoint(0x0041)
    |> result.try(unicode.name_from_codepoint)
    == Ok("LATIN CAPITAL LETTER A")
  assert string.utf_codepoint(0x03A2)
    |> result.try(unicode.name_from_codepoint)
    == Error(Nil)
  assert string.utf_codepoint(0x22C6)
    |> result.try(unicode.name_from_codepoint)
    == Ok("STAR OPERATOR")
  assert string.utf_codepoint(0x661F)
    |> result.try(unicode.name_from_codepoint)
    == Ok("CJK UNIFIED IDEOGRAPH-661F")
}

pub fn name_from_int_test() {
  assert unicode.name_from_int(0x0041) == Ok("LATIN CAPITAL LETTER A")
  assert unicode.name_from_int(0x03A2) == Error(Nil)
  assert unicode.name_from_int(0x22C6) == Ok("STAR OPERATOR")
  assert unicode.name_from_int(0x661F) == Ok("CJK UNIFIED IDEOGRAPH-661F")
  assert unicode.name_from_int(-100) == Error(Nil)
  assert unicode.name_from_int(0x110000) == Error(Nil)
}

// END

// =============================================================================
// BEGIN Unicode Blocks Tests

pub fn block_from_codepoint_test() {
  assert string.utf_codepoint(0x0041)
    |> result.map(unicode.block_from_codepoint)
    == Ok("Basic Latin")
  assert string.utf_codepoint(0x22C6)
    |> result.map(unicode.block_from_codepoint)
    == Ok("Mathematical Operators")
  assert string.utf_codepoint(0x661F)
    |> result.map(unicode.block_from_codepoint)
    == Ok("CJK Unified Ideographs")
}

pub fn block_from_int_test() {
  assert unicode.block_from_int(-100) == Error(Nil)
  assert unicode.block_from_int(0x110000) == Error(Nil)
  assert unicode.block_from_int(0x0000) == Ok("Basic Latin")
  assert unicode.block_from_int(0x0041) == Ok("Basic Latin")
  assert unicode.block_from_int(0x007F) == Ok("Basic Latin")
  assert unicode.block_from_int(0x0080) == Ok("Latin-1 Supplement")
  assert unicode.block_from_int(0x22C6) == Ok("Mathematical Operators")
  assert unicode.block_from_int(0x661F) == Ok("CJK Unified Ideographs")
  assert unicode.block_from_int(0x100000)
    == Ok("Supplementary Private Use Area-B")
}

pub fn block_to_pair_test() {
  assert unicode.block_to_pair("Basic_Latin") == Ok(#(0x0000, 0x007F))
  assert unicode.block_to_pair("isHighSurrogates") == Ok(#(0xD800, 0xDB7F))
  assert unicode.block_to_pair("Lucy") == Error(Nil)
}

pub fn block_consistency_test() {
  use block_name <- list.each(unicode.blocks())

  let assert Ok(#(start, end)) = unicode.block_to_pair(block_name)

  assert unicode.block_to_pair("is " <> string.lowercase(block_name))
    == Ok(#(start, end))

  assert start % 16 == 0
  assert end % 16 == 15

  assert unicode.block_from_int(start) == Ok(block_name)
  assert unicode.block_from_int({ end + start } / 2) == Ok(block_name)
  assert unicode.block_from_int(end) == Ok(block_name)
}

// END

// =============================================================================
// BEGIN Unicode Scripts Tests

pub fn script_name_test() {
  let assert Ok(egypt_hiero) = script.from_name("Egyp")
  assert Ok(egypt_hiero) == script.from_name("Egyptian Hieroglyphs")
  assert Ok(egypt_hiero) == script.from_name("Egyptian-Hieroglyphs")
  assert Ok(egypt_hiero) == script.from_name("is_egyptian_hieroglyphs")
  assert script.to_short_name(egypt_hiero) == "Egyp"
  assert script.to_long_name(egypt_hiero) == "Egyptian_Hieroglyphs"

  let assert Ok(coptic) = script.from_name("copt")
  assert Ok(coptic) == script.from_name("Coptic")
  assert Ok(coptic) == script.from_name("Qaac")
  assert script.to_short_name(coptic) == "Copt"
  assert script.to_long_name(coptic) == "Coptic"

  let assert Ok(inherited) = script.from_name("zinh")
  assert Ok(inherited) == script.from_name("Inherited")
  assert Ok(inherited) == script.from_name("Qaai")
  assert script.to_short_name(inherited) == "Zinh"
  assert script.to_long_name(inherited) == "Inherited"

  let assert Ok(common) = script.from_name("zyyy")
  assert Ok(common) == script.from_name("Common")
  assert script.to_short_name(common) == "Zyyy"
  assert script.to_long_name(common) == "Common"

  let assert Ok(unknown) = script.from_name("zzzz")
  assert Ok(unknown) == script.from_name("Unknown")
  assert script.to_short_name(unknown) == "Zzzz"
  assert script.to_long_name(unknown) == "Unknown"
}

pub fn script_from_int_test() {
  assert script.from_int(-100) == Error(Nil)
  assert script.from_int(0x110000) == Error(Nil)

  let assert Ok(common) = script.from_int(0x0020)
  assert script.to_short_name(common) == "Zyyy"
  assert script.from_int(0x0032) == Ok(common)
  assert script.from_int(0x005E) == Ok(common)
  assert script.from_int(0x007B) == Ok(common)
  assert script.from_int(0x00AD) == Ok(common)
  assert script.from_int(0x2028) == Ok(common)
  assert script.from_int(0x2B50) == Ok(common)

  let assert Ok(latin) = script.from_int(0x0041)
  assert script.to_long_name(latin) == "Latin"
  assert script.from_int(0x0061) == Ok(latin)
  assert script.from_int(0x01F2) == Ok(latin)
  assert script.from_int(0x02B0) == Ok(latin)
  assert script.from_int(0x2162) == Ok(latin)

  let assert Ok(inherited) = script.from_int(0x0301)
  assert script.to_short_name(inherited) == "Zinh"
  assert script.from_int(0x20E0) == Ok(inherited)

  let assert Ok(devanagari) = script.from_int(0x0903)
  assert script.to_short_name(devanagari) == "Deva"

  let assert Ok(han) = script.from_int(0x661F)
  assert script.to_long_name(han) == "Han"

  let assert Ok(unknown) = script.from_int(0xDB7F)
  assert script.to_short_name(unknown) == "Zzzz"
  assert script.from_int(0xE000) == Ok(unknown)
  assert script.from_int(0xF0000) == Ok(unknown)
  assert script.from_int(0x100000) == Ok(unknown)
}

pub fn script_from_codepoint_test() {
  let assert Ok(latin) = script.from_name("Latin")
  assert string.utf_codepoint(0x0041)
    |> result.map(script.from_codepoint)
    == Ok(latin)
  assert string.utf_codepoint(0x0061)
    |> result.map(script.from_codepoint)
    == Ok(latin)

  let assert Ok(inherited) = script.from_name("Zinh")
  assert string.utf_codepoint(0x0301)
    |> result.map(script.from_codepoint)
    == Ok(inherited)
  assert string.utf_codepoint(0x20E0)
    |> result.map(script.from_codepoint)
    == Ok(inherited)

  let assert Ok(unknown) = script.from_name("Zzzz")
  assert string.utf_codepoint(0xE000)
    |> result.map(script.from_codepoint)
    == Ok(unknown)
  assert string.utf_codepoint(0xF0000)
    |> result.map(script.from_codepoint)
    == Ok(unknown)
  assert string.utf_codepoint(0x100000)
    |> result.map(script.from_codepoint)
    == Ok(unknown)
}

pub fn script_to_pairs_test() {
  let assert Ok(braille) = script.from_name("braille")
  assert script.to_pairs(braille) == [#(0x2800, 0x28FF)]

  let assert Ok(hiragana) = script.from_name("Hira")
  assert script.to_pairs(hiragana)
    == [
      #(0x3041, 0x3096),
      #(0x309D, 0x309F),
      #(0x1B001, 0x1B11F),
      #(0x1B132, 0x1B132),
      #(0x1B150, 0x1B152),
      #(0x1F200, 0x1F200),
    ]
}

pub fn script_consistency_test() {
  use script <- list.each(script.list())

  assert script.to_short_name(script) |> script.from_name == Ok(script)
  assert script.to_long_name(script) |> script.from_name == Ok(script)

  use range <- list.each(script.to_pairs(script))
  let #(start, end) = range
  assert start <= end
  assert script.from_int(start) == Ok(script)
  assert script.from_int(end) == Ok(script)
  assert script.from_int({ start + end } / 2) == Ok(script)
}

// END

// =============================================================================
// BEGIN General Category Tests

pub fn category_from_codepoint_test() {
  assert string.utf_codepoint(0x0041)
    |> result.map(unicode.category_from_codepoint)
    == Ok(category.LetterUppercase)
  assert string.utf_codepoint(0x0032)
    |> result.map(unicode.category_from_codepoint)
    == Ok(category.NumberDecimal)
  assert string.utf_codepoint(0x0024)
    |> result.map(unicode.category_from_codepoint)
    == Ok(category.SymbolCurrency)
  assert string.utf_codepoint(0x0007)
    |> result.map(unicode.category_from_codepoint)
    == Ok(category.Control)
}

pub fn category_from_int_test() {
  assert unicode.category_from_int(0x0041) == category.LetterUppercase
  assert unicode.category_from_int(0x0061) == category.LetterLowercase
  assert unicode.category_from_int(0x01F2) == category.LetterTitlecase
  assert unicode.category_from_int(0x02B0) == category.LetterModifier
  assert unicode.category_from_int(0x661F) == category.LetterOther
  assert unicode.category_from_int(0x0301) == category.MarkNonspacing
  assert unicode.category_from_int(0x0903) == category.MarkSpacing
  assert unicode.category_from_int(0x20E0) == category.MarkEnclosing
  assert unicode.category_from_int(0x0032) == category.NumberDecimal
  assert unicode.category_from_int(0x2162) == category.NumberLetter
  assert unicode.category_from_int(0x00BD) == category.NumberOther
  assert unicode.category_from_int(0x2040) == category.PunctuationConnector
  assert unicode.category_from_int(0x2013) == category.PunctuationDash
  assert unicode.category_from_int(0x007B) == category.PunctuationOpen
  assert unicode.category_from_int(0x007D) == category.PunctuationClose
  assert unicode.category_from_int(0x201C) == category.PunctuationInitial
  assert unicode.category_from_int(0x201D) == category.PunctuationFinal
  assert unicode.category_from_int(0x0021) == category.PunctuationOther
  assert unicode.category_from_int(0x002B) == category.SymbolMath
  assert unicode.category_from_int(0x0024) == category.SymbolCurrency
  assert unicode.category_from_int(0x005E) == category.SymbolModifier
  assert unicode.category_from_int(0x2B50) == category.SymbolOther
  assert unicode.category_from_int(0x0020) == category.SeparatorSpace
  assert unicode.category_from_int(0x2028) == category.SeparatorLine
  assert unicode.category_from_int(0x2029) == category.SeparatorParagraph
  assert unicode.category_from_int(0x0007) == category.Control
  assert unicode.category_from_int(0x00AD) == category.Format
  assert unicode.category_from_int(0xD877) == category.Surrogate
  assert unicode.category_from_int(0xE777) == category.PrivateUse
  assert unicode.category_from_int(0x03A2) == category.Unassigned
}

pub fn category_from_name_test() {
  assert category.from_name("Lu") == Ok(category.LetterUppercase)
  assert category.from_name("Cn") == Ok(category.Unassigned)
  assert category.from_name("Sm") == Ok(category.SymbolMath)
  assert category.from_name("Xyz") == Error(Nil)

  assert category.from_name("Uppercase Letter") == Ok(category.LetterUppercase)
  assert category.from_name("unassigned") == Ok(category.Unassigned)
  assert category.from_name("Math-Symbol") == Ok(category.SymbolMath)
  assert category.from_name("Invalid_Category") == Error(Nil)
}

pub fn category_to_short_name_test() {
  assert category.to_short_name(category.LetterUppercase) == "Lu"
  assert category.to_short_name(category.Unassigned) == "Cn"
  assert category.to_short_name(category.SymbolMath) == "Sm"
}

pub fn category_to_long_name_test() {
  assert category.to_long_name(category.LetterUppercase) == "Uppercase_Letter"
  assert category.to_long_name(category.Unassigned) == "Unassigned"
  assert category.to_long_name(category.SymbolMath) == "Math_Symbol"
}

pub fn category_is_assigned_test() {
  assert category.is_assigned(category.LetterLowercase)
  assert !category.is_assigned(category.Surrogate)
  assert !category.is_assigned(category.Unassigned)
}

pub fn category_is_cased_letter_test() {
  assert category.is_cased_letter(category.LetterLowercase)
  assert !category.is_cased_letter(category.LetterOther)
}

pub fn category_is_letter_test() {
  assert category.is_letter(category.LetterLowercase)
  assert !category.is_letter(category.NumberDecimal)
}

pub fn category_is_mark_test() {
  assert category.is_mark(category.MarkSpacing)
  assert !category.is_mark(category.NumberDecimal)
}

pub fn category_is_number_test() {
  assert category.is_number(category.NumberDecimal)
  assert !category.is_number(category.LetterLowercase)
}

pub fn category_is_punctuation_test() {
  assert category.is_punctuation(category.PunctuationOther)
  assert !category.is_punctuation(category.NumberDecimal)
}

pub fn category_is_quotation_test() {
  assert category.is_quotation(category.PunctuationInitial)
  assert !category.is_quotation(category.PunctuationOpen)
}

pub fn category_is_symbol_test() {
  assert category.is_symbol(category.SymbolCurrency)
  assert !category.is_symbol(category.NumberDecimal)
}

pub fn category_is_separator_test() {
  assert category.is_separator(category.SeparatorSpace)
  assert !category.is_separator(category.NumberDecimal)
}

pub fn category_is_other_test() {
  assert category.is_other(category.Control)
  assert !category.is_other(category.NumberDecimal)
}

pub fn category_is_graphic_test() {
  assert category.is_graphic(category.LetterLowercase)
  assert !category.is_graphic(category.Control)
}

pub fn category_is_format_test() {
  assert category.is_format(category.Format)
  assert category.is_format(category.SeparatorLine)
  assert category.is_format(category.SeparatorParagraph)
  assert !category.is_format(category.Control)
}

pub fn category_consistency_test() {
  use cat <- list.each(category.list)

  let short_name = category.to_short_name(cat)
  assert Ok(cat) == category.from_name(short_name)

  let long_name = category.to_long_name(cat)
  assert Ok(cat) == category.from_name(long_name)

  assert case short_name {
    "L" <> _ -> category.is_letter(cat)
    "M" <> _ -> category.is_mark(cat)
    "N" <> _ -> category.is_number(cat)
    "P" <> _ -> category.is_punctuation(cat)
    "S" <> _ -> category.is_symbol(cat)
    "Z" <> _ -> category.is_separator(cat)
    "C" <> _ -> category.is_other(cat)
    _ -> False
  }

  assert case long_name {
    "Control" | "Format" | "Surrogate" | "Private_Use" | "Unassigned" ->
      category.is_other(cat)
    _ ->
      case string.split_once(long_name, on: "_") {
        Ok(#(_, "Letter")) -> category.is_letter(cat)
        Ok(#(_, "Mark")) -> category.is_mark(cat)
        Ok(#(_, "Number")) -> category.is_number(cat)
        Ok(#(_, "Punctuation")) -> category.is_punctuation(cat)
        Ok(#(_, "Symbol")) -> category.is_symbol(cat)
        Ok(#(_, "Separator")) -> category.is_separator(cat)
        _ -> False
      }
  }
}
// END
