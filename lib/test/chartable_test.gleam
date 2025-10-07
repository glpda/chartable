import chartable
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn property_matching_test() {
  assert chartable.comparable_property(" Basic Latin ") == "basiclatin"
  assert chartable.comparable_property("LINE BREAK") == "linebreak"
  assert chartable.comparable_property("Line_Break") == "linebreak"
  assert chartable.comparable_property("Line-break") == "linebreak"
  assert chartable.comparable_property("isGreek") == "greek"
  assert chartable.comparable_property("Is_Greek") == "greek"
  assert chartable.comparable_property("isistooconvoluted") == "istooconvoluted"
  assert chartable.comparable_property("Isolated") == "olated"
  assert chartable.comparable_property("IS") == "is"
}
