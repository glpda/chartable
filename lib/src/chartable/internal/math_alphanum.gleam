//// [Wikipedia: Mathematical Alphanumeric Symbols](https://en.wikipedia.org/wiki/Mathematical_Alphanumeric_Symbols)
////
//// [Unicode Chart: Letterlike Symbols](https://www.unicode.org/charts/PDF/U2100.pdf)
////
//// [Unicode Chart: Mathematical Alphanumeric Symbols](https://www.unicode.org/charts/PDF/U1D400.pdf)

import gleam/result
import gleam/string

pub type Weight {
  Regular
  Bold
}

pub type Slope {
  Upright
  Italic
}

pub type Style {
  LatinSerif(letter: UtfCodepoint, slope: Slope, weight: Weight)
  LatinScript(letter: UtfCodepoint, weight: Weight)
  LatinFraktur(letter: UtfCodepoint, weight: Weight)
  LatinDoubleStruck(letter: UtfCodepoint)
  LatinSans(letter: UtfCodepoint, slope: Slope, weight: Weight)
  LatinMono(letter: UtfCodepoint)
  GreekSerif(letter: UtfCodepoint, slope: Slope, weight: Weight)
  GreekDoubleStruck(letter: UtfCodepoint)
  GreekSansBold(letter: UtfCodepoint, slope: Slope)
  DigitSerif(letter: UtfCodepoint, weight: Weight)
  DigitDoubleStruck(letter: UtfCodepoint)
  DigitSans(letter: UtfCodepoint, weight: Weight)
  DigitMono(letter: UtfCodepoint)
  Hebrew(letter: UtfCodepoint)
}

pub fn from_codepoint(codepoint: UtfCodepoint) -> Result(Style, Nil) {
  let cp = string.utf_codepoint
  case string.utf_codepoint_to_int(codepoint) {
    // Digits:
    int if 0x0030 <= int && int <= 0x0039 -> Ok(DigitSerif(codepoint, Regular))
    // Uppercase Latin Letters:
    int if 0x0041 <= int && int <= 0x005A ->
      Ok(LatinSerif(codepoint, Upright, Regular))
    // Lowercase Latin Letters:
    int if 0x0061 <= int && int <= 0x007A ->
      Ok(LatinSerif(codepoint, Upright, Regular))
    // Greek Uppercase Letters:
    int if 0x0391 <= int && int <= 0x03A9 && int != 0x03A2 ->
      Ok(GreekSerif(codepoint, Upright, Regular))
    // Greek Lowercase Letters:
    int if 0x03B1 <= int && int <= 0x03C9 ->
      Ok(GreekSerif(codepoint, Upright, Regular))
    // Beta Symbol (ϐ):
    // 0x03D0 -> Ok(GreekSerif(codepoint, Italic, Regular))
    // Lowercase Theta Symbol (ϑ):
    0x03D1 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Phi Symbol (ϕ):
    0x03D5 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Pi Symbol (ϖ):
    0x03D6 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Uppercase Digamma (Ϝ):
    0x03DC -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Lowercase Digamma (ϝ):
    0x03DD -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Kappa Symbol (ϰ):
    0x03F0 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Rho Symbol (ϱ):
    0x03F1 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Uppercase Theta Symbol (ϴ):
    0x03F4 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Lunate Epsilon Symbol (ϵ):
    0x03F5 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Complex Numbers, Double-Struck C (ℂ):
    0x2102 -> cp(0x0043) |> result.map(LatinDoubleStruck)
    // Script g (ℊ):
    0x210A -> cp(0x0067) |> result.map(LatinScript(_, Regular))
    // Hamiltonian OPerator, Script H (ℋ):
    0x210B -> cp(0x0048) |> result.map(LatinScript(_, Regular))
    // Hilbert Space, Fraktur H (ℌ):
    0x210C -> cp(0x0048) |> result.map(LatinFraktur(_, Regular))
    // Double-Struck H (ℍ):
    0x210D -> cp(0x0048) |> result.map(LatinDoubleStruck)
    // Planck Constant, Italic h (ℎ):
    0x210E -> cp(0x0068) |> result.map(LatinSerif(_, Italic, Regular))
    // Script I (ℐ):
    0x2110 -> cp(0x0049) |> result.map(LatinScript(_, Regular))
    // Imaginary Part, Fraktur I (ℑ):
    0x2111 -> cp(0x0049) |> result.map(LatinFraktur(_, Regular))
    // Script L (ℒ):
    0x2112 -> cp(0x004C) |> result.map(LatinScript(_, Regular))
    // NOTE 0x2113 Script l (ℓ) not a predecessor of 0x1D4C1 Math Script l (𝓁)
    // Natural Numbers, Double-Struck N (ℕ):
    0x2115 -> cp(0x004E) |> result.map(LatinDoubleStruck)
    // NOTE 0x2118 Weierstrass Elliptic Function, Script P (℘)?
    // Double-Struck P (ℙ):
    0x2119 -> cp(0x0050) |> result.map(LatinDoubleStruck)
    // Rational Numbers, Double-Struck Q (ℚ):
    0x211A -> cp(0x0051) |> result.map(LatinDoubleStruck)
    // Riemann Integral, Script R (ℛ):
    0x211B -> cp(0x0052) |> result.map(LatinScript(_, Regular))
    // Real Part, Fraktur R (ℜ):
    0x211C -> cp(0x0052) |> result.map(LatinFraktur(_, Regular))
    // Real Numbers, Double-Struck R (ℝ):
    0x211D -> cp(0x0052) |> result.map(LatinDoubleStruck)
    // Integer Numbers, Double-Struck Z (ℤ):
    0x2124 -> cp(0x005A) |> result.map(LatinDoubleStruck)
    // Fraktur Z (ℨ):
    0x2128 -> cp(0x005A) |> result.map(LatinFraktur(_, Regular))
    // Bernoulli Function, Script B (ℬ):
    0x212C -> cp(0x0042) |> result.map(LatinScript(_, Regular))
    // Fraktur C (ℭ):
    0x212D -> cp(0x0043) |> result.map(LatinFraktur(_, Regular))
    // Error, Natural Exponent, Script e (ℯ):
    0x212F -> cp(0x0065) |> result.map(LatinScript(_, Regular))
    // emf (ElectroMotive Force) Script E (ℰ):
    0x2130 -> cp(0x0045) |> result.map(LatinScript(_, Regular))
    // Fourier Transform, Script F (ℱ):
    0x2131 -> cp(0x0046) |> result.map(LatinScript(_, Regular))
    // Matrix, Script M (ℳ):
    0x2133 -> cp(0x004D) |> result.map(LatinScript(_, Regular))
    // Script o (ℴ):
    0x2134 -> cp(0x006F) |> result.map(LatinScript(_, Regular))
    // Hebrew Symbols 0x2135..0x2138 (ℵ, ℶ, ℷ, ℸ):
    int if 0x2135 <= int && int <= 0x2138 ->
      cp(int - 0x2135 + 0x05D0) |> result.map(Hebrew)
    // Double-Struck Lowercase Pi (ℼ):
    0x213C -> cp(0x03C0) |> result.map(GreekDoubleStruck)
    // Double-Struck Lowercase Gamma (ℽ):
    0x213D -> cp(0x03B3) |> result.map(GreekDoubleStruck)
    // Double-Struck Uppercase Gamma (ℾ):
    0x213E -> cp(0x0393) |> result.map(GreekDoubleStruck)
    // Double-Struck Uppercase Pi (ℿ):
    0x213F -> cp(0x03A0) |> result.map(GreekDoubleStruck)
    // Summation, Double-Struck Uppercase Sigma (⅀):
    0x2140 -> cp(0x03A3) |> result.map(GreekDoubleStruck)
    // Differential, Double-Struck D (ⅅ):
    0x2145 -> cp(0x0044) |> result.map(LatinDoubleStruck)
    // Differential, Double-Struck d (ⅆ):
    0x2146 -> cp(0x0064) |> result.map(LatinDoubleStruck)
    // Natural Exponent, Double-Struck e (ⅇ):
    0x2147 -> cp(0x0065) |> result.map(LatinDoubleStruck)
    // Imaginary Unit, Double-Struck i (ⅈ):
    0x2148 -> cp(0x0069) |> result.map(LatinDoubleStruck)
    // Imaginary Unit, Double-Struck j (ⅉ):
    0x2149 -> cp(0x006A) |> result.map(LatinDoubleStruck)
    // Partial differential (∂):
    0x2202 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Nabla (∇):
    0x2207 -> Ok(GreekSerif(codepoint, Upright, Regular))
    // Exclude reserved code points ("holes"):
    0x1D455
    | 0x1D49D
    | 0x1D4A0
    | 0x1D4A1
    | 0x1D4A3
    | 0x1D4A4
    | 0x1D4A7
    | 0x1D4A8
    | 0x1D4AD
    | 0x1D4BA
    | 0x1D4BC
    | 0x1D4C4
    | 0x1D506
    | 0x1D50B
    | 0x1D50C
    | 0x1D515
    | 0x1D51D
    | 0x1D53A
    | 0x1D53F
    | 0x1D545
    | 0x1D547
    | 0x1D548
    | 0x1D549
    | 0x1D551 -> Error(Nil)
    // Latin Letters
    int if 0x1D400 <= int && int <= 0x1D6A3 -> latin_style(int)
    // Dotless Italic i (𝚤):
    0x1D6A4 -> cp(0x0131) |> result.map(LatinSerif(_, Italic, Regular))
    // Dotless Italic j (𝚥):
    0x1D6A5 -> cp(0x0237) |> result.map(LatinSerif(_, Italic, Regular))
    // Greek Letters:
    int if 0x1D6A8 <= int && int <= 0x1D7C9 -> greek_style(int)
    // Bold Uppercase Digamma (𝟊):
    0x1D7CA -> cp(0x03DC) |> result.map(GreekSerif(_, Upright, Bold))
    // Bold Lowercase Digamma (𝟋):
    0x1D7CB -> cp(0x03DD) |> result.map(GreekSerif(_, Upright, Bold))
    // Digits:
    int if 0x1D7CE <= int && int <= 0x1D7FF -> digit_style(int)
    _ -> Error(Nil)
  }
}

fn latin_style(codepoint: Int) -> Result(Style, Nil) {
  let int = codepoint - 0x1D400
  let class = int / 0x34
  let index = int % 0x34
  case class {
    00 -> latin_codepoint(index) |> result.map(LatinSerif(_, Upright, Bold))
    01 -> latin_codepoint(index) |> result.map(LatinSerif(_, Italic, Regular))
    02 -> latin_codepoint(index) |> result.map(LatinSerif(_, Italic, Bold))
    03 -> latin_codepoint(index) |> result.map(LatinScript(_, Regular))
    04 -> latin_codepoint(index) |> result.map(LatinScript(_, Bold))
    05 -> latin_codepoint(index) |> result.map(LatinFraktur(_, Regular))
    06 -> latin_codepoint(index) |> result.map(LatinDoubleStruck)
    07 -> latin_codepoint(index) |> result.map(LatinFraktur(_, Bold))
    08 -> latin_codepoint(index) |> result.map(LatinSans(_, Upright, Regular))
    09 -> latin_codepoint(index) |> result.map(LatinSans(_, Upright, Bold))
    10 -> latin_codepoint(index) |> result.map(LatinSans(_, Italic, Regular))
    11 -> latin_codepoint(index) |> result.map(LatinSans(_, Italic, Bold))
    12 -> latin_codepoint(index) |> result.map(LatinMono)
    _ -> Error(Nil)
  }
}

fn latin_codepoint(index: Int) -> Result(UtfCodepoint, Nil) {
  case index {
    // Uppercase:
    index if 0 <= index && index <= 25 -> string.utf_codepoint(0x0041 + index)
    // Lowercase:
    index if 26 <= index && index <= 51 ->
      string.utf_codepoint(0x0061 + index - 26)
    _ -> Error(Nil)
  }
}

fn greek_style(codepoint: Int) -> Result(Style, Nil) {
  let int = codepoint - 0x1D6A8
  let class = int / 0x3A
  let index = int % 0x3A
  case class {
    0 -> greek_codepoint(index) |> result.map(GreekSerif(_, Upright, Bold))
    1 -> greek_codepoint(index) |> result.map(GreekSerif(_, Italic, Regular))
    2 -> greek_codepoint(index) |> result.map(GreekSerif(_, Italic, Bold))
    3 -> greek_codepoint(index) |> result.map(GreekSansBold(_, Upright))
    4 -> greek_codepoint(index) |> result.map(GreekSansBold(_, Italic))
    _ -> Error(Nil)
  }
}

fn greek_codepoint(index: Int) -> Result(UtfCodepoint, Nil) {
  case index {
    // Uppercase Theta Symbol (ϴ):
    17 -> string.utf_codepoint(0x03F4)
    // Uppercase (Α..Ω):
    index if 0 <= index && index <= 24 -> string.utf_codepoint(0x0391 + index)
    // Nabla (∇):
    25 -> string.utf_codepoint(0x2207)
    // Lowercase (α..ω):
    index if 26 <= index && index <= 50 ->
      string.utf_codepoint(0x03B1 + index - 26)
    // Partial differential (∂):
    51 -> string.utf_codepoint(0x2202)
    // Lunate Epsilon Symbol (ϵ):
    52 -> string.utf_codepoint(0x03F5)
    // Lowercase Theta Symbol (ϑ):
    53 -> string.utf_codepoint(0x03D1)
    // Kappa Symbol (ϰ):
    54 -> string.utf_codepoint(0x03F0)
    // Phi Symbol (ϕ):
    55 -> string.utf_codepoint(0x03D5)
    // Rho Symbol (ϱ):
    56 -> string.utf_codepoint(0x03F1)
    // Pi Symbol (ϖ):
    57 -> string.utf_codepoint(0x03D6)
    _ -> Error(Nil)
  }
}

fn digit_style(codepoint: Int) -> Result(Style, Nil) {
  let int = codepoint - 0x1D7CE
  let class = int / 10
  let index = int % 10
  case class {
    0 -> digit_codepoint(index) |> result.map(DigitSerif(_, Bold))
    1 -> digit_codepoint(index) |> result.map(DigitDoubleStruck)
    2 -> digit_codepoint(index) |> result.map(DigitSans(_, Bold))
    3 -> digit_codepoint(index) |> result.map(DigitSans(_, Regular))
    4 -> digit_codepoint(index) |> result.map(DigitMono)
    _ -> Error(Nil)
  }
}

fn digit_codepoint(index: Int) -> Result(UtfCodepoint, Nil) {
  string.utf_codepoint(0x0030 + index)
}
