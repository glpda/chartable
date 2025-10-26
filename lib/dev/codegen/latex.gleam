import chartable/latex/math_type.{type MathType}
import chartable/unicode/codepoint
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

/// Parses `tex-math.txt` extracted from
/// [TeX for the Impatient](https://mirrors.ctan.org/info/impatient/book.pdf).
pub fn parse_texmath_symbols(
  txt txt: String,
) -> Result(List(MathSymbol), ParserError) {
  let comment = parser.Anywhere(["//"])
  let space = splitter.new([" "])
  use line <- parser.parse_lines(txt:, comment:, reducer: list.reverse)
  // alpha ABC α
  let #(notation, _, rest) = splitter.split(space, line)
  let #(tag, _, rest) = splitter.split(space, rest)
  use math_type <- result.try(
    tag_to_math_type(tag) |> result.replace_error("Invalid MathType"),
  )
  let #(grapheme, _, _) = splitter.split(space, rest)
  use codepoint <- result.try(case string.to_utf_codepoints(grapheme) {
    [codepoint] -> Ok(codepoint)
    _ -> Error("Invalid Codepoint")
  })
  Ok(MathSymbol(codepoint:, math_type:, notation:))
}

/// Parses `unicode-math-table.tex` from LaTeX3 unicode-math package
/// ([CTAN](https://www.ctan.org/pkg/unicode-math),
/// [GitHub](https://github.com/latex3/unicode-math)).
pub fn parse_unimath_symbols(
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
    codepoint.parse_utf(hex) |> result.replace_error("Invalid Codepoint"),
  )
  let #(command, _, rest) = splitter.split(curly, rest)
  let #(math_type, _, _) = splitter.split(curly, rest)
  use math_type <- result.try(
    math_type.from_tex(math_type)
    |> result.replace_error("Invalid MathType"),
  )
  let notation = string.trim(command) |> string.drop_start(up_to: 1)
  Ok(MathSymbol(codepoint:, math_type:, notation:))
}

pub fn math_symbols_to_notation_table(unimath_symbols: List(MathSymbol)) {
  let notation_to_grapheme =
    list.fold(
      over: unimath_symbols,
      from: dict.new(),
      with: fn(notation_to_grapheme, math_symbol) {
        let MathSymbol(codepoint:, notation:, ..) = math_symbol
        let grapheme = string.from_utf_codepoints([codepoint])
        dict.insert(grapheme, into: notation_to_grapheme, for: notation)
      },
    )
  notation_table.complement_notation_to_grapheme(notation_to_grapheme)
}

pub fn javascript_math_map(
  math_symbols records: List(MathSymbol),
  template template: String,
  data_source data_source: String,
) -> String {
  let math_records =
    list.map(records, fn(record) {
      let codepoint = codepoint.utf_to_hex(record.codepoint)
      let math_type = math_type_to_tag(record.math_type)
      let notation = record.notation
      "[0x" <> codepoint <> ", " <> math_type <> ", \"" <> notation <> "\"]"
    })
    |> string.join(with: ",\n")

  string.replace(in: template, each: "{{data_source}}", with: data_source)
  |> string.replace(each: "/*{{math_records}}*/", with: math_records)
}

pub fn math_type_to_tag(math_type: MathType) -> String {
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

pub fn tag_to_math_type(tag: String) -> Result(MathType, Nil) {
  case tag {
    "ORD" -> Ok(math_type.Ordinary)
    "ABC" -> Ok(math_type.Alphabetic)
    "ACC" -> Ok(math_type.Accent)
    "ACW" -> Ok(math_type.AcentWide)
    "BOT" -> Ok(math_type.BottomAccent)
    "BOW" -> Ok(math_type.BottomAccentWide)
    "LAY" -> Ok(math_type.AccentOverlay)
    "BIN" -> Ok(math_type.BinaryOperation)
    "REL" -> Ok(math_type.Relation)
    "LOP" -> Ok(math_type.LargeOperator)
    "RAD" -> Ok(math_type.Radical)
    "OPN" -> Ok(math_type.Opening)
    "CLO" -> Ok(math_type.Closing)
    "FEN" -> Ok(math_type.Fencing)
    "OVR" -> Ok(math_type.Over)
    "NDR" -> Ok(math_type.Under)
    "PUN" -> Ok(math_type.Punctuation)
    _ -> Error(Nil)
  }
}
