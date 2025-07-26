import chartable/unicode
import chartable/unicode/category
import gleam/list
import gleam/result
import gleam/string

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

  assert unicode.category_from_int(0x304B) == category.LetterOther

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

  assert unicode.category_from_int(0x00B0) == category.SymbolOther

  assert unicode.category_from_int(0x0020) == category.SeparatorSpace

  assert unicode.category_from_int(0x2028) == category.SeparatorLine

  assert unicode.category_from_int(0x2029) == category.SeparatorParagraph

  assert unicode.category_from_int(0x0007) == category.Control

  assert unicode.category_from_int(0x00AD) == category.Format

  assert unicode.category_from_int(0xD877) == category.Surrogate

  assert unicode.category_from_int(0xE777) == category.PrivateUse

  assert unicode.category_from_int(0x03A2) == category.Unassigned
}

pub fn category_from_abbreviation_test() {
  assert category.from_abbreviation("Lu") == Ok(category.LetterUppercase)

  assert category.from_abbreviation("Cn") == Ok(category.Unassigned)

  assert category.from_abbreviation("Sm") == Ok(category.SymbolMath)

  assert category.from_abbreviation("Xyz") == Error(Nil)
}

pub fn category_to_abbreviation_test() {
  assert category.to_abbreviation(category.LetterUppercase) == "Lu"

  assert category.to_abbreviation(category.Unassigned) == "Cn"

  assert category.to_abbreviation(category.SymbolMath) == "Sm"
}

pub fn category_from_long_name_test() {
  assert category.from_long_name("Uppercase_Letter")
    == Ok(category.LetterUppercase)

  assert category.from_long_name("Unassigned") == Ok(category.Unassigned)

  assert category.from_long_name("Math_Symbol") == Ok(category.SymbolMath)

  assert category.from_long_name("Invalid_Category") == Error(Nil)
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

pub fn is_punctuation_test() {
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

fn assert_category_consistency(cat) {
  let abbr = category.to_abbreviation(cat)
  assert Ok(cat) == category.from_abbreviation(abbr)

  let name = category.to_long_name(cat)
  assert Ok(cat) == category.from_long_name(name)

  assert case abbr {
    "L" <> _ -> category.is_letter(cat)
    "M" <> _ -> category.is_mark(cat)
    "N" <> _ -> category.is_number(cat)
    "P" <> _ -> category.is_punctuation(cat)
    "S" <> _ -> category.is_symbol(cat)
    "Z" <> _ -> category.is_separator(cat)
    "C" <> _ -> category.is_other(cat)
    _ -> False
  }

  assert case name {
    "Control" | "Format" | "Surrogate" | "Private_Use" | "Unassigned" ->
      category.is_other(cat)

    _ ->
      case string.split_once(name, on: "_") {
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

pub fn category_consistency_test() {
  let categories = [
    // Letters:
    category.LetterUppercase,
    category.LetterLowercase,
    category.LetterTitlecase,
    category.LetterModifier,
    category.LetterOther,
    // Marks:
    category.MarkNonspacing,
    category.MarkSpacing,
    category.MarkEnclosing,
    // Numbers:
    category.NumberDecimal,
    category.NumberLetter,
    category.NumberOther,
    // Punctuations:
    category.PunctuationConnector,
    category.PunctuationDash,
    category.PunctuationOpen,
    category.PunctuationClose,
    category.PunctuationInitial,
    category.PunctuationFinal,
    category.PunctuationOther,
    // Symbols:
    category.SymbolMath,
    category.SymbolCurrency,
    category.SymbolModifier,
    category.SymbolOther,
    // Separators:
    category.SeparatorSpace,
    category.SeparatorLine,
    category.SeparatorParagraph,
    // Others:
    category.Control,
    category.Format,
    category.Surrogate,
    category.PrivateUse,
    category.Unassigned,
  ]
  list.each(categories, assert_category_consistency)
}
