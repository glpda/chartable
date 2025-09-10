import chartable/unicode
import chartable/unicode/category
import chartable/unicode/codepoint
import chartable/unicode/script
import gleam/list
import gleam/result
import gleam/string

const example_codepoints = [
  0x0041, 0x0061, 0x01F2, 0x02B0, 0x661F, 0x0301, 0x0903, 0x20E0, 0x0032, 0x2162,
  0x00BD, 0x2040, 0x2013, 0x007B, 0x007D, 0x201C, 0x201D, 0x0021, 0x002B, 0x0024,
  0x005E, 0x2B50, 0x0020, 0x2028, 0x2029, 0x0007, 0x00AD, 0xDB7F, 0xE777, 0x03A2,
]

// =============================================================================
// BEGIN Unicode Code Points Tests

pub fn codepoint_test() {
  assert codepoint.from_int(-100) == Error(Nil)
  assert codepoint.from_int(0x110000) == Error(Nil)

  use int <- list.each([0, 0x10FFFF, ..example_codepoints])
  let assert Ok(cp) = codepoint.from_int(int)
  assert codepoint.to_int(cp) == int
  case string.utf_codepoint(int) {
    Error(_) -> {
      assert codepoint.to_utf(cp) == Error(Nil)
    }
    Ok(utf) -> {
      assert codepoint.to_utf(cp) == Ok(utf)
      assert codepoint.from_utf(utf) == cp
    }
  }
}

pub fn codepoint_range_test() {
  let assert Error(_) = codepoint.range_from_ints(-100, 0)
  let assert Error(_) = codepoint.range_from_ints(100, -50)
  let assert Error(_) = codepoint.range_from_ints(-50, -100)
  let assert Error(_) = codepoint.range_from_ints(0x0041, 0x110000)
  let assert Error(_) = codepoint.range_from_ints(0x120000, 0)
  let assert Error(_) = codepoint.range_from_ints(0x110000, 0x120000)

  use #(left, right) <- list.each([
    #(0x0000, 0x007F),
    #(0x009F, 0x0080),
    #(0x2800, 0x28FF),
    #(0x309F, 0x3040),
    #(0x05FF, 0x0590),
    #(0x661F, 0x661F),
    #(0xD800, 0xDFFF),
    #(0xF0000, 0xFFFFF),
    #(0x10FFFF, 0x100000),
  ])
  let assert Ok(range) = codepoint.range_from_ints(left, right)
  case left <= right {
    True -> {
      assert #(left, right) == codepoint.range_to_ints(range)
    }
    False -> {
      assert #(right, left) == codepoint.range_to_ints(range)
    }
  }
  let assert Ok(left) = codepoint.from_int(left)
  let assert Ok(right) = codepoint.from_int(right)
  assert codepoint.range_from_codepoints(left, right) == range
  assert codepoint.range_from_codepoints(right, left) == range
}

// END

// =============================================================================
// BEGIN Unicode Name Tests

pub fn name_from_codepoint_test() {
  let name_from_int = fn(cp) {
    result.try(codepoint.from_int(cp), unicode.name_from_codepoint)
  }
  assert name_from_int(0x0041) == Ok("LATIN CAPITAL LETTER A")
  assert name_from_int(0x03A2) == Error(Nil)
  assert name_from_int(0x22C6) == Ok("STAR OPERATOR")
  assert name_from_int(0x661F) == Ok("CJK UNIFIED IDEOGRAPH-661F")
}

// END

// =============================================================================
// BEGIN Unicode Blocks Tests

pub fn block_from_codepoint_test() {
  let block_from_int = fn(cp) {
    result.map(codepoint.from_int(cp), unicode.block_from_codepoint)
  }
  assert block_from_int(0x0000) == Ok("Basic Latin")
  assert block_from_int(0x0041) == Ok("Basic Latin")
  assert block_from_int(0x007F) == Ok("Basic Latin")
  assert block_from_int(0x0080) == Ok("Latin-1 Supplement")
  assert block_from_int(0x22C6) == Ok("Mathematical Operators")
  assert block_from_int(0x661F) == Ok("CJK Unified Ideographs")
  assert block_from_int(0x100000) == Ok("Supplementary Private Use Area-B")
}

pub fn block_to_range_test() {
  let block_to_pair = fn(block) {
    result.map(unicode.block_to_range(block), codepoint.range_to_ints)
  }
  assert block_to_pair("Basic_Latin") == Ok(#(0x0000, 0x007F))
  assert block_to_pair("isHighSurrogates") == Ok(#(0xD800, 0xDB7F))
  assert block_to_pair("Lucy") == Error(Nil)
}

pub fn block_consistency_test() {
  use block_name <- list.each(unicode.blocks())
  let assert Ok(block_range) = unicode.block_to_range(block_name)

  let #(start, end) = codepoint.range_to_codepoints(block_range)
  assert unicode.block_from_codepoint(start) == block_name
  assert unicode.block_from_codepoint(end) == block_name

  let #(start, end) = codepoint.range_to_ints(block_range)
  assert start % 16 == 0
  assert end % 16 == 15
  let assert Ok(cp) = codepoint.from_int({ start + end } / 2)
  assert unicode.block_from_codepoint(cp) == block_name
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

pub fn script_from_codepoint_test() {
  let script_from_int = fn(cp) {
    result.map(codepoint.from_int(cp), script.from_codepoint)
  }
  let assert Ok(common) = script_from_int(0x0020)
  assert script.to_short_name(common) == "Zyyy"
  assert script_from_int(0x0032) == Ok(common)
  assert script_from_int(0x005E) == Ok(common)
  assert script_from_int(0x007B) == Ok(common)
  assert script_from_int(0x00AD) == Ok(common)
  assert script_from_int(0x2028) == Ok(common)
  assert script_from_int(0x2B50) == Ok(common)

  let assert Ok(latin) = script_from_int(0x0041)
  assert script.to_long_name(latin) == "Latin"
  assert script_from_int(0x0061) == Ok(latin)
  assert script_from_int(0x01F2) == Ok(latin)
  assert script_from_int(0x02B0) == Ok(latin)
  assert script_from_int(0x2162) == Ok(latin)

  let assert Ok(inherited) = script_from_int(0x0301)
  assert script.to_short_name(inherited) == "Zinh"
  assert script_from_int(0x20E0) == Ok(inherited)

  let assert Ok(devanagari) = script_from_int(0x0903)
  assert script.to_short_name(devanagari) == "Deva"

  let assert Ok(han) = script_from_int(0x661F)
  assert script.to_long_name(han) == "Han"

  let assert Ok(unknown) = script_from_int(0xDB7F)
  assert script.to_short_name(unknown) == "Zzzz"
  assert script_from_int(0xE000) == Ok(unknown)
  assert script_from_int(0xF0000) == Ok(unknown)
  assert script_from_int(0x100000) == Ok(unknown)
}

pub fn script_to_ranges_test() {
  let assert Ok(unknown) = script.from_name("Zzzz")
  assert script.to_ranges(unknown) == []

  let assert Ok(braille) = script.from_name("braille")
  assert script.to_ranges(braille) |> list.map(codepoint.range_to_ints)
    == [#(0x2800, 0x28FF)]

  let assert Ok(hiragana) = script.from_name("hira")
  assert script.to_ranges(hiragana) |> list.map(codepoint.range_to_ints)
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

  use range <- list.each(script.to_ranges(script))
  let #(start, end) = codepoint.range_to_codepoints(range)
  assert script.from_codepoint(start) == script
  assert script.from_codepoint(end) == script
  let #(start, end) = codepoint.range_to_ints(range)
  let assert Ok(cp) = codepoint.from_int({ start + end } / 2)
  assert script.from_codepoint(cp) == script
}

// END

// =============================================================================
// BEGIN General Category Tests

pub fn category_from_codepoint_test() {
  use #(cp, cat) <- list.each(list.zip(example_codepoints, category.list))
  let assert Ok(cp) = codepoint.from_int(cp)
  assert unicode.category_from_codepoint(cp) == cat
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
