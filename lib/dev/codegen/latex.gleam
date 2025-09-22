import chartable/internal
import chartable/latex/math_type.{type MathType}
import codegen/notation_table
import codegen/parser.{type ParserError}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import splitter

pub type MathSymbol {
  MathSymbol(codepoint: UtfCodepoint, math_type: MathType, notation: String)
}

/// Parses `unicode-math-table.tex` from LaTeX3 unicode-math package
/// ([CTAN](https://www.ctan.org/pkg/unicode-math),
/// [GitHub](https://github.com/latex3/unicode-math))
pub fn parse_math_symbols(
  tex txt: String,
) -> Result(List(MathSymbol), ParserError) {
  // \UnicodeMathSymbol{"00021}{\mathexclam   }{\mathclose}{exclamation mark}%
  let curly = splitter.new(["}{"])
  let comment = parser.Anywhere(["%"])
  use line <- parser.parse_lines(txt:, comment:, reducer: list.reverse)
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
    math_type.from_tex(math_type)
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
