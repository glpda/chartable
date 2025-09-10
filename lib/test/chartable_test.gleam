import chartable/internal
import gleam/string
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn parse_utf_test() {
  assert internal.parse_utf("0000") == string.utf_codepoint(0x0000)
  assert internal.parse_utf("0041") == string.utf_codepoint(0x0041)
  assert internal.parse_utf("2B50") == string.utf_codepoint(0x2B50)
  assert internal.parse_utf("661F") == string.utf_codepoint(0x661F)
  assert internal.parse_utf("120000") == Error(Nil)
}

pub fn int_to_hex_test() {
  assert internal.int_to_hex(0x0000) == "0000"
  assert internal.int_to_hex(0x0041) == "0041"
  assert internal.int_to_hex(0x2B50) == "2B50"
  assert internal.int_to_hex(0x661F) == "661F"
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
