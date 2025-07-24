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
  assert string.utf_codepoint(0x4E55)
    |> result.try(unicode.name_from_codepoint)
    == Ok("CJK UNIFIED IDEOGRAPH-4E55")
}

pub fn name_from_int_test() {
  assert unicode.name_from_int(0x0041) == Ok("LATIN CAPITAL LETTER A")
  assert unicode.name_from_int(0x03A2) == Error(Nil)
  assert unicode.name_from_int(0x22C6) == Ok("STAR OPERATOR")
  assert unicode.name_from_int(0x4E55) == Ok("CJK UNIFIED IDEOGRAPH-4E55")
}

pub fn category_from_abbreviation_test() {
  assert Ok(category.LetterUppercase) == category.from_abbreviation("Lu")
  assert Ok(category.Unassigned) == category.from_abbreviation("Cn")
  assert Ok(category.SymbolMath) == category.from_abbreviation("Sm")
  assert Error(Nil) == category.from_abbreviation("Xyz")
}

pub fn category_to_abbreviation_test() {
  assert "Lu" == category.to_abbreviation(category.LetterUppercase)
  assert "Cn" == category.to_abbreviation(category.Unassigned)
  assert "Sm" == category.to_abbreviation(category.SymbolMath)
}

pub fn category_from_long_name_test() {
  assert Ok(category.LetterUppercase)
    == category.from_long_name("Uppercase_Letter")
  assert Ok(category.Unassigned) == category.from_long_name("Unassigned")
  assert Ok(category.SymbolMath) == category.from_long_name("Math_Symbol")
  assert Error(Nil) == category.from_abbreviation("Xyz")
}

pub fn category_to_long_name_test() {
  assert "Uppercase_Letter" == category.to_long_name(category.LetterUppercase)
  assert "Unassigned" == category.to_long_name(category.Unassigned)
  assert "Math_Symbol" == category.to_long_name(category.SymbolMath)
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
