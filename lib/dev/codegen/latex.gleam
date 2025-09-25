import chartable/internal
import chartable/latex/math_type.{type MathType}
import codegen/notation_table
import codegen/parser.{type ParserError}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import splitter

pub type UnimathSymbol {
  UnimathSymbol(codepoint: UtfCodepoint, math_type: MathType, notation: String)
}

/// Parses `unicode-math-table.tex` from LaTeX3 unicode-math package
/// ([CTAN](https://www.ctan.org/pkg/unicode-math),
/// [GitHub](https://github.com/latex3/unicode-math)).
pub fn parse_unimath_symbols(
  tex txt: String,
) -> Result(List(UnimathSymbol), ParserError) {
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
    math_type.from_tex(math_type)
    |> result.replace_error("Invalid MathType"),
  )
  UnimathSymbol(codepoint:, math_type:, notation: string.trim(notation))
}

pub fn unimath_symbols_to_notation_table(unimath_symbols: List(UnimathSymbol)) {
  let notation_to_grapheme =
    list.fold(
      over: unimath_symbols,
      from: dict.new(),
      with: fn(notation_to_grapheme, math_symbol) {
        let UnimathSymbol(codepoint:, notation:, ..) = math_symbol
        let grapheme = string.from_utf_codepoints([codepoint])
        dict.insert(grapheme, into: notation_to_grapheme, for: notation)
      },
    )
  notation_table.complement_notation_to_grapheme(notation_to_grapheme)
}

pub fn javascript_unimath_map(
  unimath_symbols records: List(UnimathSymbol),
  template template: String,
) -> String {
  let unimath_records =
    list.map(records, fn(record) {
      let codepoint = internal.utf_to_hex(record.codepoint)
      let math_type = javascript_math_type(record.math_type)
      let notation = string.drop_start(from: record.notation, up_to: 1)
      "[0x" <> codepoint <> ", " <> math_type <> ", \"" <> notation <> "\"]"
    })
    |> string.join(with: ",\n")

  string.replace(
    in: template,
    each: "/*{{unimath_records}}*/",
    with: unimath_records,
  )
}

pub fn javascript_math_type(math_type: MathType) -> String {
  case math_type {
    math_type.Ordinary -> "ORD"
    math_type.Alphabetic -> "ABC"
    math_type.Accent -> "ACC"
    math_type.AcentWide -> "ACW"
    math_type.BottomAccent -> "BOT"
    math_type.BottomAccentWide -> "BOW"
    math_type.AccentOverlay -> "LAY"
    math_type.BinaryOperation -> "BIN"
    math_type.Relation -> "REL"
    math_type.LargeOperator -> "LOP"
    math_type.Radical -> "RAD"
    math_type.Opening -> "OPN"
    math_type.Closing -> "CLO"
    math_type.Fencing -> "FEN"
    math_type.Over -> "OVR"
    math_type.Under -> "NDR"
    math_type.Punctuation -> "PUN"
  }
}
