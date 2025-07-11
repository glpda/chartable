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
