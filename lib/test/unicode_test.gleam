import chartable/unicode/category

pub fn category_to_abbreviation_test() {
  assert "Lu" == category.to_abbreviation(category.LetterUppercase)
  assert "Cn" == category.to_abbreviation(category.Unassigned)
  assert "Sm" == category.to_abbreviation(category.SymbolMath)
}

pub fn category_from_abbreviation_test() {
  assert Ok(category.LetterUppercase) == category.from_abbreviation("Lu")
  assert Ok(category.Unassigned) == category.from_abbreviation("Cn")
  assert Ok(category.SymbolMath) == category.from_abbreviation("Sm")
  assert Error(Nil) == category.from_abbreviation("Xyz")
}
