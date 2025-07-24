import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile
import splitter

type Record(fields) {
  Record(codepoint_range: CodepointRange, fields: fields)
}

type CodepointRange {
  CodepointRange(from: UtfCodepoint, to: UtfCodepoint)
  SingleCodepoint(UtfCodepoint)
}

pub fn main() {
  let assert Ok(names) = simplifile.read("data/unicode/names.txt")
  let assert Ok(codegen_src) = simplifile.read("data/unicode/name_map.mjs")
  assert Ok(Nil) == make_unicode_name_map(names:, codegen_src:)

  Nil
}

fn codepoint_to_hex(cp: UtfCodepoint) -> String {
  string.utf_codepoint_to_int(cp)
  |> int.to_base16()
  |> string.pad_start(to: 4, with: "0")
}

fn make_unicode_name_map(names names: String, codegen_src codegen_src: String) {
  let names = parse_unicode_data(names)

  let if_ranges =
    list.filter_map(names, fn(record) {
      case record {
        Record(CodepointRange(from: start, to: end), [name, ..]) if name != "" -> {
          let start = codepoint_to_hex(start)
          let end = codepoint_to_hex(end)
          // if ((0x3400 <= cp) && (cp <= 0x4DBF)) {
          //   return new Ok("CJK UNIFIED IDEOGRAPH-" + display_codepoint(cp) + "");
          // } else
          let if_in_range =
            "if ((0x" <> start <> " <= cp) && (cp <= 0x" <> end <> ")) {\n"
          let display_codepoint = "\" + display_codepoint(cp) + \""
          let name =
            string.replace(in: name, each: "*", with: display_codepoint)
          let return_name = "    return new Ok(\"" <> name <> "\");\n"
          Ok(if_in_range <> return_name <> "  } else ")
        }
        Record(CodepointRange(..), _) -> Error(Nil)
        Record(SingleCodepoint(_), _) -> Error(Nil)
      }
    })
    |> string.concat()

  let map_def =
    list.filter_map(names, fn(record) {
      case record {
        Record(SingleCodepoint(cp), [name, ..]) if name != "" -> {
          let cp = codepoint_to_hex(cp)
          let name = string.replace(in: name, each: "*", with: cp)
          // TODO assert name is (uppercase letter + space + dash)
          // [0x0020, "SPACE"],
          Ok("[0x" <> cp <> ", \"" <> name <> "\"],\n")
        }
        Record(SingleCodepoint(_), _) -> Error(Nil)
        Record(CodepointRange(..), _) -> Error(Nil)
      }
    })
    |> string.concat()

  let contents =
    string.replace(in: codegen_src, each: "/*{{if_ranges}}*/", with: if_ranges)
    |> string.replace(each: "/*{{map_def}}*/", with: map_def)
  simplifile.write(to: "src/chartable/unicode/name_map.mjs", contents:)
}

fn parse_unicode_data(txt: String) -> List(Record(List(String))) {
  let line_end = splitter.new(["\n"])
  let comment = splitter.new(["#"])
  let separator = splitter.new([";"])
  let records = []

  use txt <- parse_unicode_data_loop(input: txt, output: records)
  let #(line, _, rest) = splitter.split(line_end, txt)
  let #(line, _, _) = splitter.split(comment, line)
  use <- bool.guard(when: string.is_empty(line), return: #(None, rest))
  let #(first_field, _, other_fields) = splitter.split(separator, line)
  let codepoint_range = parse_codepoint_range(first_field)
  let fields = string.split(other_fields, on: ";") |> list.map(string.trim)
  #(Some(Record(codepoint_range:, fields:)), rest)
}

fn parse_unicode_data_loop(
  input str: String,
  output records: List(Record(fields)),
  with line_parser: fn(String) -> #(Option(Record(fields)), String),
) {
  case str {
    "" -> list.reverse(records)
    _ ->
      case line_parser(str) {
        #(Some(record), rest) -> {
          let output = [record, ..records]
          parse_unicode_data_loop(rest, output:, with: line_parser)
        }
        #(None, rest) ->
          parse_unicode_data_loop(rest, output: records, with: line_parser)
      }
  }
}

fn parse_codepoint_range(str: String) -> CodepointRange {
  case string.split_once(str, on: "..") {
    Ok(#(start, end)) -> {
      let assert Ok(start) = string.trim(start) |> parse_codepoint()
      let assert Ok(end) = string.trim(end) |> parse_codepoint()
      CodepointRange(from: start, to: end)
    }
    Error(_) -> {
      let assert Ok(codepoint) = string.trim(str) |> parse_codepoint()
      SingleCodepoint(codepoint)
    }
  }
}

fn parse_codepoint(str: String) -> Result(UtfCodepoint, Nil) {
  int.base_parse(str, 16) |> result.try(string.utf_codepoint)
}
