import chartable/internal
import chartable/latex/math_type.{type MathType as LatexMathType} as latex_math_type
import chartable/unicode/math_class.{type MathClass as UnicodeMathClass} as unicode_math_class
import codegen/notation_table
import codegen/parser.{type ParserError}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import splitter

pub type MathSymbol {
  MathSymbol(
    codepoint: UtfCodepoint,
    math_type: LatexMathType,
    notation: String,
  )
}

/// Parses `unicode-math-table.tex` from LaTeX3 unicode-math package
/// ([CTAN](https://www.ctan.org/pkg/unicode-math),
/// [GitHub](https://github.com/latex3/unicode-math))
pub fn parse_math_symbols(
  tex txt: String,
) -> Result(List(MathSymbol), ParserError) {
  let curly = splitter.new(["}{"])
  let comment = parser.Anywhere(["%"])
  use line <- parser.parse_lines(txt:, comment:, reducer: list.reverse)
  // \UnicodeMathSymbol{"00021}{\mathexclam   }{\mathclose}{exclamation mark}%
  use rest <- result.try(case line {
    "\\UnicodeMathSymbol{\"" <> rest -> Ok(rest)
    _ -> Error("Invalid Command")
  })
  let #(hex, _, rest) = splitter.split(curly, rest)
  use codepoint <- result.try(
    internal.parse_utf(hex) |> result.replace_error("Invalid Codepoint"),
  )
  let #(notation, _, rest) = splitter.split(curly, rest)
  let #(math_type, _, _) = splitter.split(curly, rest)
  use math_type <- result.map(
    latex_math_type.from_tex(math_type)
    |> result.replace_error("Invalid MathType"),
  )
  MathSymbol(codepoint:, math_type:, notation: string.trim(notation))
}

pub fn math_symbols_to_notation_table(math_symbols: List(MathSymbol)) {
  let notation_to_grapheme =
    list.fold(
      over: math_symbols,
      from: dict.new(),
      with: fn(notation_to_grapheme, math_symbol) {
        let MathSymbol(codepoint:, notation:, ..) = math_symbol
        let grapheme = string.from_utf_codepoints([codepoint])
        dict.insert(grapheme, into: notation_to_grapheme, for: notation)
      },
    )
  notation_table.complement_notation_to_grapheme(notation_to_grapheme)
}

pub type UnimathRecord {
  UnimathRecord(
    codepoint: UtfCodepoint,
    unicode_math_class: Option(UnicodeMathClass),
    latex_math_type: Option(LatexMathType),
    text_notation: String,
    math_notation: String,
  )
}

/// Parses `unimathsymbols.txt` from the LaTeX Unicode Character References (LUCR).
pub fn parse_lucr_unimath(
  txt: String,
) -> Result(List(UnimathRecord), ParserError) {
  // let carret = splitter.new(["^"])
  let comment = parser.LineStart(["#"])

  use line <- parser.parse_lines(txt:, comment:, reducer: list.reverse)
  // cp^char^LaTeX^unicode-math^unicode_math_class^latex_math_type^requirements^comments
  case string.split(line, on: "^") {
    [hex, _char, text_notation, math_notation, f5, f6, ..] -> {
      use codepoint <- result.try(
        internal.parse_utf(hex) |> result.replace_error("Invalid Codepoint"),
      )
      // assert _char == string.from_utf_codepoints([codepoint])
      let unimath_record =
        UnimathRecord(
          codepoint:,
          unicode_math_class: None,
          latex_math_type: None,
          text_notation:,
          math_notation:,
        )
      case
        unicode_math_class.from_name(f5),
        latex_math_type.from_tex("\\" <> f6)
      {
        _, _ if f5 == "" && f6 == "" -> Ok(unimath_record)
        Ok(unicode_math_class), _ if f6 == "" ->
          Ok(
            UnimathRecord(
              ..unimath_record,
              unicode_math_class: Some(unicode_math_class),
            ),
          )

        _, Ok(latex_math_type) if f5 == "" ->
          Ok(
            UnimathRecord(
              ..unimath_record,
              latex_math_type: Some(latex_math_type),
            ),
          )
        Ok(unicode_math_class), Ok(latex_math_type) ->
          Ok(
            UnimathRecord(
              ..unimath_record,
              unicode_math_class: Some(unicode_math_class),
              latex_math_type: Some(latex_math_type),
            ),
          )
        Error(_), Ok(_) -> Error("Invalid Unicode MathClass")
        Ok(_), Error(_) -> Error("Invalid LaTeX MathType")
        Error(_), Error(_) ->
          Error("Invalid Unicode MathClass & Invalid LaTeX MathTyp")
      }
    }

    _ -> Error("Missing Fields")
  }
}

pub fn lucr_unimath_to_notation_table(lucr_unimath: List(UnimathRecord)) {
  let grapheme_to_notations =
    list.fold(
      over: lucr_unimath,
      from: dict.new(),
      with: fn(grapheme_to_notations, unimath_record) {
        let UnimathRecord(codepoint:, text_notation:, math_notation:, ..) =
          unimath_record
        let grapheme = string.from_utf_codepoints([codepoint])
        case text_notation, math_notation {
          "", "" -> grapheme_to_notations
          notation, "" ->
            dict.insert([notation], into: grapheme_to_notations, for: grapheme)
          "", notation ->
            dict.insert([notation], into: grapheme_to_notations, for: grapheme)
          text_notation, math_notation ->
            dict.insert(
              [text_notation, math_notation],
              into: grapheme_to_notations,
              for: grapheme,
            )
        }
      },
    )
  notation_table.complement_grapheme_to_notations(grapheme_to_notations)
}
