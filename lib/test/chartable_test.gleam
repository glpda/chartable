import chartable/internal
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn property_matching_test() {
  assert internal.comparable_property(" Basic Latin ") == "basiclatin"
  assert internal.comparable_property("LINE BREAK") == "linebreak"
  assert internal.comparable_property("Line_Break") == "linebreak"
  assert internal.comparable_property("Line-break") == "linebreak"
  assert internal.comparable_property("isGreek") == "greek"
  assert internal.comparable_property("Is_Greek") == "greek"
  assert internal.comparable_property("isistooconvoluted") == "istooconvoluted"
  assert internal.comparable_property("Isolated") == "olated"
  assert internal.comparable_property("IS") == "is"
}
