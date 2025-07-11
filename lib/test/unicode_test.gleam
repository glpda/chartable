import chartable/unicode/category

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

pub fn from_long_name_test() {
  assert Ok(category.LetterUppercase)
    == category.from_long_name("Uppercase_Letter")
  assert Ok(category.Unassigned) == category.from_long_name("Unassigned")
  assert Ok(category.SymbolMath) == category.from_long_name("Math_Symbol")
  assert Error(Nil) == category.from_abbreviation("Xyz")
}

pub fn to_long_name_test() {
  assert "Uppercase_Letter" == category.to_long_name(category.LetterUppercase)
  assert "Unassigned" == category.to_long_name(category.Unassigned)
  assert "Math_Symbol" == category.to_long_name(category.SymbolMath)
}

pub fn is_cased_letter_test() {
  assert category.is_cased_letter(category.LetterLowercase)
  assert !category.is_cased_letter(category.LetterOther)
}

pub fn is_letter_test() {
  assert category.is_letter(category.LetterLowercase)
  assert !category.is_letter(category.NumberDecimal)
}

pub fn is_mark_test() {
  assert category.is_mark(category.MarkSpacing)
  assert !category.is_mark(category.NumberDecimal)
}

pub fn is_number_test() {
  assert category.is_number(category.NumberDecimal)
  assert !category.is_number(category.LetterLowercase)
}

pub fn is_punctuation_test() {
  assert category.is_punctuation(category.PunctuationOther)
  assert !category.is_punctuation(category.NumberDecimal)
}

pub fn is_quotation_test() {
  assert category.is_quotation(category.PunctuationIntial)
  assert !category.is_quotation(category.PunctuationOpen)
}

pub fn is_symbol_test() {
  assert category.is_symbol(category.SymbolCurrency)
  assert !category.is_symbol(category.NumberDecimal)
}

pub fn is_separator_test() {
  assert category.is_separator(category.SeparatorSpace)
  assert !category.is_separator(category.NumberDecimal)
}

pub fn is_other_test() {
  assert category.is_other(category.Control)
  assert !category.is_other(category.NumberDecimal)
}
