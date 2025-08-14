//// Converts between Unicode code points and [typst notations](https://typst.app/docs/reference)

import chartable/internal/math_alphanum.{Bold, Italic, Regular, Upright}
import gleam/list
import gleam/result
import gleam/string

@external(javascript, "./typst/symbol_map.mjs", "grapheme_to_notations")
fn symbol_grapheme_to_notations(grapheme: String) -> List(String)

@external(javascript, "./typst/symbol_map.mjs", "notation_to_grapheme")
fn symbol_notation_to_grapheme(notation: String) -> Result(String, Nil)

@external(javascript, "./typst/emoji_map.mjs", "grapheme_to_notations")
fn emoji_grapheme_to_notations(grapheme: String) -> List(String)

@external(javascript, "./typst/emoji_map.mjs", "notation_to_grapheme")
fn emoji_notation_to_grapheme(notation: String) -> Result(String, Nil)

/// Converts a grapheme `String` to a Typst symbol notation `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/sym/)).
///
/// ## Examples
///
/// ```gleam
/// assert typst.symbols_from_grapheme("⋆") == ["#sym.star.op"]
///
/// assert typst.symbols_from_grapheme("$")
///   == ["#sym.dollar", "#sym.pataca", "#sym.peso"]
/// ```
///
pub fn symbols_from_grapheme(grapheme: String) -> List(String) {
  symbol_grapheme_to_notations(grapheme)
  |> list.map(string.append(_, to: "#sym."))
}

/// Converts a `UtfCodepoint` to a Typst symbol notation `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/sym/)).
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x22C6)
///   |> result.map(typst.symbols_from_codepoint)
///   == Ok(["#sym.star.op"])
///
/// assert string.utf_codepoint(0x0024)
///   |> result.map(typst.symbols_from_codepoint)
///   == Ok(["#sym.dollar", "#sym.pataca", "#sym.peso"])
/// ```
///
pub fn symbols_from_codepoint(codepoint: UtfCodepoint) -> List(String) {
  string.from_utf_codepoints([codepoint])
  |> symbols_from_grapheme()
}

/// Converts a grapheme `String` to a Typst emoji notation `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/emoji/)).
///
/// ## Examples
///
/// ```gleam
/// assert typst.emojis_from_grapheme("⭐") == ["#emoji.star"]
///
/// assert typst.emojis_from_grapheme("🌟") == ["#emoji.star.glow"]
/// ```
///
pub fn emojis_from_grapheme(grapheme: String) -> List(String) {
  emoji_grapheme_to_notations(grapheme)
  |> list.map(string.append(_, to: "#emoji."))
}

/// Converts a `UtfCodepoint` to a Typst emoji notation `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/emoji/)).
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x2B50)
///   |> result.map(typst.emojis_from_codepoint)
///   == Ok(["#emoji.star"])
///
/// assert string.utf_codepoint(0x1F31F)
///   |> result.map(typst.emojis_from_codepoint)
///   == Ok(["#emoji.star.glow"])
/// ```
///
pub fn emojis_from_codepoint(codepoint: UtfCodepoint) -> List(String) {
  string.from_utf_codepoints([codepoint])
  |> emojis_from_grapheme()
}

/// Converts a Typst markup mode shorthand `String` to a `UtfCodepoint`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// assert typst.markup_shorthand_to_codepoint("--")
///   == string.utf_codepoint(0x2013)
/// ```
///
pub fn markup_shorthand_to_codepoint(
  shorthand: String,
) -> Result(UtfCodepoint, Nil) {
  case shorthand {
    // en dash (–):
    "--" -> string.utf_codepoint(0x2013)
    // em dash (—):
    "---" -> string.utf_codepoint(0x2014)
    // horizontal ellipsis (…):
    "..." -> string.utf_codepoint(0x2026)
    // soft hyphen (shy):
    "-?" -> string.utf_codepoint(0x00AD)
    // minus sign (−):
    "-" -> string.utf_codepoint(0x2212)
    // no break space (nbsp):
    "~" -> string.utf_codepoint(0x00A0)
    _ -> Error(Nil)
  }
}

/// Converts a Typst markup mode shorthand `String` to a grapheme `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// assert typst.markup_shorthand_to_grapheme("--") == Ok("–")
/// ```
///
pub fn markup_shorthand_to_grapheme(shorthand: String) -> Result(String, Nil) {
  markup_shorthand_to_codepoint(shorthand)
  |> result.map(fn(codepoint) { string.from_utf_codepoints([codepoint]) })
}

/// Converts a `UtfCodepoint` to a Typst markup mode shorthand `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(en_dash) = string.utf_codepoint(0x2013)  // '–'
///
/// assert typst.markup_shorthand_from_codepoint(en_dash) == Ok("--")
/// ```
///
pub fn markup_shorthand_from_codepoint(
  codepoint: UtfCodepoint,
) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    // en dash (–):
    0x2013 -> Ok("--")
    // em dash (—):
    0x2014 -> Ok("---")
    // horizontal ellipsis (…):
    0x2026 -> Ok("...")
    // soft hyphen (shy):
    0x00AD -> Ok("-?")
    // minus sign (−):
    0x2212 -> Ok("-")
    // no break space (nbsp):
    0x00A0 -> Ok("~")
    _ -> Error(Nil)
  }
}

/// Converts a grapheme `String` to a Typst markup mode shorthand `String`
/// (see [Typst docs](https://typst.app/docs/reference/symbols/#shorthands)).
///
/// ## Examples
///
/// ```gleam
/// assert typst.markup_shorthand_from_grapheme("–") == Ok("--")
/// ```
///
pub fn markup_shorthand_from_grapheme(grapheme: String) -> Result(String, Nil) {
  case string.to_utf_codepoints(grapheme) {
    [codepoint] -> markup_shorthand_from_codepoint(codepoint)
    _ -> Error(Nil)
  }
}

/// Converts a Typst math mode shorthand `String` to a `UtfCodepoint`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// assert typst.math_shorthand_to_codepoint("->") == string.utf_codepoint(0x2192)
/// ```
///
pub fn math_shorthand_to_codepoint(
  shorthand: String,
) -> Result(UtfCodepoint, Nil) {
  case shorthand {
    // rightwards arrow (→):
    "->" -> string.utf_codepoint(0x2192)
    // rightwards arrow from bar (↦):
    "|->" -> string.utf_codepoint(0x21A6)
    // rightwards double arrow (⇒):
    "=>" -> string.utf_codepoint(0x21D2)
    // rightwards double arrow from bar (⤇):
    "|=>" -> string.utf_codepoint(0x2907)
    // long rightwards double arrow (⟹):
    "==>" -> string.utf_codepoint(0x27F9)
    // long rightwards arrow (⟶):
    "-->" -> string.utf_codepoint(0x27F6)
    // long rightwards squiggle arrow (⟿):
    "~~>" -> string.utf_codepoint(0x27FF)
    // rightwards squiggle arrow (⇝):
    "~>" -> string.utf_codepoint(0x21DD)
    // rightwards arrow with tail (↣):
    ">->" -> string.utf_codepoint(0x21A3)
    // rightwards two headed arrow (↠):
    "->>" -> string.utf_codepoint(0x21A0)
    // leftwards arrow (←):
    "<-" -> string.utf_codepoint(0x2190)
    // leftwards long double arrow (⟸):
    "<==" -> string.utf_codepoint(0x27F8)
    // long leftwards arrow (⟵):
    "<--" -> string.utf_codepoint(0x27F5)
    // long leftwards squiggle arrow (⬳):
    "<~~" -> string.utf_codepoint(0x2B33)
    // leftwards squiggle arrow (⇜):
    "<~" -> string.utf_codepoint(0x21DC)
    // leftwards arrow with tail (↢):
    "<-<" -> string.utf_codepoint(0x21A2)
    // leftwards two headed arrow (↞):
    "<<-" -> string.utf_codepoint(0x219E)
    // left right arrow (↔):
    "<->" -> string.utf_codepoint(0x2194)
    // left right double arrow (⇔):
    "<=>" -> string.utf_codepoint(0x21D4)
    // long left right double arrow (⟺):
    "<==>" -> string.utf_codepoint(0x27FA)
    // long left right arrow (⟷):
    "<-->" -> string.utf_codepoint(0x27F7)
    // asterisk operator (∗):
    "*" -> string.utf_codepoint(0x2217)
    // double vertical line (‖):
    "||" -> string.utf_codepoint(0x2016)
    // left white square bracker (⟦):
    "[|" -> string.utf_codepoint(0x27E6)
    // right white square bracker (⟧):
    "|]" -> string.utf_codepoint(0x27E7)
    // colon equals (≔):
    ":=" -> string.utf_codepoint(0x2254)
    // double colon equals (⩴):
    "::=" -> string.utf_codepoint(0x2A74)
    // horizontal ellipsis (…):
    "..." -> string.utf_codepoint(0x2026)
    // equals colon (≕):
    "=:" -> string.utf_codepoint(0x2255)
    // not equal to (≠):
    "!=" -> string.utf_codepoint(0x2260)
    // much greater than (≫):
    ">>" -> string.utf_codepoint(0x226B)
    // greater than or equal to (≥):
    ">=" -> string.utf_codepoint(0x2265)
    // very much greater than (⋙):
    ">>>" -> string.utf_codepoint(0x22D9)
    // much less than (≪):
    "<<" -> string.utf_codepoint(0x226A)
    // less than or equal to (≤):
    "<=" -> string.utf_codepoint(0x2264)
    // very much less than (⋘):
    "<<<" -> string.utf_codepoint(0x22D8)
    // minus sign (−):
    "-" -> string.utf_codepoint(0x2212)
    // tilde operator (∼):
    "~" -> string.utf_codepoint(0x223C)
    // prime (′):
    "'" -> string.utf_codepoint(0x2032)
    // double pime (″):
    "''" -> string.utf_codepoint(0x2033)
    // triple prime (‴):
    "'''" -> string.utf_codepoint(0x2034)
    // quadruple prime (⁗):
    "''''" -> string.utf_codepoint(0x2057)
    _ -> Error(Nil)
  }
}

/// Converts a Typst math mode shorthand `String` to a grapheme `String`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// assert typst.math_shorthand_to_grapheme("->") == Ok("→")
///
/// ```
///
pub fn math_shorthand_to_grapheme(shorthand: String) -> Result(String, Nil) {
  math_shorthand_to_codepoint(shorthand)
  |> result.map(fn(codepoint) { string.from_utf_codepoints([codepoint]) })
}

/// Converts a `UtfCodepoint` to a Typst math mode shorthand `String`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(arrow) = string.utf_codepoint(0x2192)  // '→'
///
/// assert typst.math_shorthand_from_codepoint(arrow) == Ok("->")
/// ```
///
pub fn math_shorthand_from_codepoint(
  codepoint: UtfCodepoint,
) -> Result(String, Nil) {
  case string.utf_codepoint_to_int(codepoint) {
    // rightwards arrow (→):
    0x2192 -> Ok("->")
    // rightwards arrow from bar (↦):
    0x21A6 -> Ok("|->")
    // rightwards double arrow (⇒):
    0x21D2 -> Ok("=>")
    // rightwards double arrow from bar (⤇):
    0x2907 -> Ok("|=>")
    // long rightwards double arrow (⟹):
    0x27F9 -> Ok("==>")
    // long rightwards arrow (⟶):
    0x27F6 -> Ok("-->")
    // long rightwards squiggle arrow (⟿):
    0x27FF -> Ok("~~>")
    // rightwards squiggle arrow (⇝):
    0x21DD -> Ok("~>")
    // rightwards arrow with tail (↣):
    0x21A3 -> Ok(">->")
    // rightwards two headed arrow (↠):
    0x21A0 -> Ok("->>")
    // leftwards arrow (←):
    0x2190 -> Ok("<-")
    // leftwards long double arrow (⟸):
    0x27F8 -> Ok("<==")
    // long leftwards arrow (⟵):
    0x27F5 -> Ok("<--")
    // long leftwards squiggle arrow (⬳):
    0x2B33 -> Ok("<~~")
    // leftwards squiggle arrow (⇜):
    0x21DC -> Ok("<~")
    // leftwards arrow with tail (↢):
    0x21A2 -> Ok("<-<")
    // leftwards two headed arrow (↞):
    0x219E -> Ok("<<-")
    // left right arrow (↔):
    0x2194 -> Ok("<->")
    // left right double arrow (⇔):
    0x21D4 -> Ok("<=>")
    // long left right double arrow (⟺):
    0x27FA -> Ok("<==>")
    // long left right arrow (⟷):
    0x27F7 -> Ok("<-->")
    // asterisk operator (∗):
    0x2217 -> Ok("*")
    // double vertical line (‖):
    0x2016 -> Ok("||")
    // left white square bracker (⟦):
    0x27E6 -> Ok("[|")
    // right white square bracker (⟧):
    0x27E7 -> Ok("|]")
    // colon equals (≔):
    0x2254 -> Ok(":=")
    // double colon equals (⩴):
    0x2A74 -> Ok("::=")
    // horizontal ellipsis (…):
    0x2026 -> Ok("...")
    // equals colon (≕):
    0x2255 -> Ok("=:")
    // not equal to (≠):
    0x2260 -> Ok("!=")
    // much greater than (≫):
    0x226B -> Ok(">>")
    // greater than or equal to (≥):
    0x2265 -> Ok(">=")
    // very much greater than (⋙):
    0x22D9 -> Ok(">>>")
    // much less than (≪):
    0x226A -> Ok("<<")
    // less than or equal to (≤):
    0x2264 -> Ok("<=")
    // very much less than (⋘):
    0x22D8 -> Ok("<<<")
    // minus sign (−):
    0x2212 -> Ok("-")
    // tilde operator (∼):
    0x223C -> Ok("~")
    // prime (′):
    0x2032 -> Ok("'")
    // double pime (″):
    0x2033 -> Ok("''")
    // triple prime (‴):
    0x2034 -> Ok("'''")
    // quadruple prime (⁗):
    0x2057 -> Ok("''''")
    _ -> Error(Nil)
  }
}

/// Converts a grapheme `String` to a Typst math mode shorthand `String`:
/// - [Math Shorthands](https://typst.app/docs/reference/symbols/#shorthands)
/// - [Math Primes](https://typst.app/docs/reference/math/primes/)
///
/// ## Examples
///
/// ```gleam
/// assert typst.math_shorthand_from_grapheme("→") == Ok("->")
/// ```
///
pub fn math_shorthand_from_grapheme(grapheme: String) -> Result(String, Nil) {
  case string.to_utf_codepoints(grapheme) {
    [codepoint] -> math_shorthand_from_codepoint(codepoint)
    _ -> Error(Nil)
  }
}

// pub fn math_alphanum_from_grapheme(grapheme: String) {
//   TODO
// }

/// Converts a `UtfCodepoint` to a Typst math alphanumeric symbol:
/// - [Math Styles](https://typst.app/docs/reference/math/styles)
/// - [Math Variants](https://typst.app/docs/reference/math/variants)
///
/// ## Examples
///
/// ```gleam
/// assert string.utf_codepoint(0x0043)
///   |> result.try(typst.math_alphanum_from_codepoint)
///   == Ok(["upright(C)"])
///
/// assert string.utf_codepoint(0x1D436)
///   |> result.try(typst.math_alphanum_from_codepoint)
///   == Ok(["C"])
///
/// assert string.utf_codepoint(0x1D53A)
///   |> result.try(typst.math_alphanum_from_codepoint)
///   == Error(Nil)
///
/// assert string.utf_codepoint(0x2102)
///   |> result.try(typst.math_alphanum_from_codepoint)
///   == Ok(["bb(C)"])
///
/// assert string.utf_codepoint(0x1D6AA)
///   |> result.try(typst.math_alphanum_from_codepoint)
///   == Ok(["bold(Gamma)"])
/// ```
///
pub fn math_alphanum_from_codepoint(
  codepoint: UtfCodepoint,
) -> Result(List(String), Nil) {
  use alphanum <- result.try(math_alphanum.from_codepoint(codepoint))
  let grapheme = string.from_utf_codepoints([alphanum.letter])
  let notations = case symbol_grapheme_to_notations(grapheme) {
    [] -> [grapheme]
    notations -> notations
  }

  // NOTE: "italic" default for roman letters and greek _lowercase_ letters
  let math_styles = case alphanum {
    math_alphanum.LatinSerif(_, Italic, Regular) -> []
    math_alphanum.DigitSerif(_, Regular) -> []
    math_alphanum.LatinSerif(_, Italic, Bold) -> ["bold"]
    math_alphanum.DigitSerif(_, Bold) -> ["bold"]
    math_alphanum.LatinSerif(_, Upright, Regular) -> ["upright"]
    math_alphanum.LatinSerif(_, Upright, Bold) -> ["upright", "bold"]
    math_alphanum.LatinScript(_, Regular) -> ["cal"]
    math_alphanum.LatinScript(_, Bold) -> ["cal", "bold"]
    math_alphanum.LatinFraktur(_, Regular) -> ["frak"]
    math_alphanum.LatinFraktur(_, Bold) -> ["frak", "bold"]
    math_alphanum.LatinSans(_, Italic, Regular) -> ["sans"]
    math_alphanum.DigitSans(_, Regular) -> ["sans"]
    math_alphanum.LatinSans(_, Italic, Bold) -> ["sans", "bold"]
    math_alphanum.DigitSans(_, Bold) -> ["sans", "bold"]
    math_alphanum.LatinSans(_, Upright, Regular) -> ["upright", "sans"]
    math_alphanum.LatinSans(_, Upright, Bold) -> ["upright", "sans", "bold"]
    math_alphanum.LatinMono(_) -> ["mono"]
    math_alphanum.DigitMono(_) -> ["mono"]
    math_alphanum.LatinDoubleStruck(_) -> ["bb"]
    math_alphanum.DigitDoubleStruck(_) -> ["bb"]
    math_alphanum.GreekDoubleStruck(_) -> ["bb"]
    math_alphanum.GreekSerif(letter, slope, Regular) ->
      greek_slope(letter, slope, [])
    math_alphanum.GreekSerif(letter, slope, Bold) ->
      greek_slope(letter, slope, ["bold"])
    math_alphanum.GreekSansBold(letter:, slope:) ->
      greek_slope(letter, slope, ["sans"])
    math_alphanum.Hebrew(_) -> []
  }

  Ok(list.map(notations, apply_math_styles(_, math_styles)))
}

fn greek_slope(
  letter: UtfCodepoint,
  slope: math_alphanum.Slope,
  styles: List(String),
) -> List(String) {
  let grapheme = string.from_utf_codepoints([letter])
  let is_lowercase =
    grapheme == string.lowercase(grapheme)
    && grapheme != string.uppercase(grapheme)
  case slope {
    Italic if is_lowercase -> styles
    Italic -> ["italic", ..styles]
    Upright if is_lowercase -> ["upright", ..styles]
    Upright -> styles
  }
}

fn apply_math_styles(string: String, styles: List(String)) -> String {
  case styles {
    [] -> string
    [style, ..rest] -> apply_math_styles(style <> "(" <> string <> ")", rest)
  }
}

/// Converts a Typst codex name `String` to a grapheme `String`,
/// only handles names listed in these two modules:
/// [sym](https://typst.app/docs/reference/symbols/sym/),
/// and [emoji](https://typst.app/docs/reference/symbols/emoji/).
///
/// ## Examples
///
/// ```gleam
/// assert typst.notation_to_grapheme("#sym.star.op") == Ok("\u{22C6}")
///
/// assert typst.notation_to_grapheme("#emoji.star") == Ok("\u{2B50}")
///
/// assert typst.notation_to_grapheme("emoji.star") == Error(Nil)
///
/// assert typst.notation_to_grapheme("#emoji.staaar") == Error(Nil)
/// ```
///
pub fn notation_to_grapheme(notation: String) -> Result(String, Nil) {
  case notation {
    "#sym." <> name -> symbol_notation_to_grapheme(name)
    "#emoji." <> name -> emoji_notation_to_grapheme(name)
    _ -> Error(Nil)
  }
}

fn display_math(string: String) -> String {
  "$ " <> string <> " $"
}

/// Converts a grapheme `String` to a `List` of Typst notations `String`.
///
/// ## Examples
///
/// ```gleam
/// assert typst.notations_from_grapheme("\u{1F31F}") == ["#emoji.star.glow"]
///
/// assert typst.notations_from_grapheme("\u{22C6}") == ["#sym.star.op"]
///
/// assert typst.notations_from_grapheme("\u{2013}") == ["#sym.dash.en", "--"]
///
/// assert typst.notations_from_grapheme("\u{2192}") == ["#sym.arrow.r", "$ -> $"]
///
/// assert typst.notations_from_grapheme("\u{0393}")
///   == ["#sym.Gamma", "$ Gamma $"]
///
/// assert typst.notations_from_grapheme("\u{1D6AA}") == ["$ bold(Gamma) $"]
/// ```
///
pub fn notations_from_grapheme(grapheme: String) -> List(String) {
  let sym_notations = symbols_from_grapheme(grapheme)
  let emoji_notations = emojis_from_grapheme(grapheme)

  sym_notations
  |> list.append(emoji_notations)
  |> list.append(case string.to_utf_codepoints(grapheme) {
    [codepoint] -> {
      let markup_shorthand =
        markup_shorthand_from_codepoint(codepoint)
        |> result.map(list.wrap)
        |> result.unwrap([])
      let math_shorthand =
        math_shorthand_from_codepoint(codepoint)
        |> result.map(list.wrap)
        |> result.unwrap([])
        |> list.map(display_math)
      let math_alphanum_notations =
        math_alphanum_from_codepoint(codepoint)
        |> result.unwrap([])
        |> list.map(display_math)

      markup_shorthand
      |> list.append(math_shorthand)
      |> list.append(math_alphanum_notations)
    }
    _ -> []
  })
}
