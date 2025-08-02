import chartable/internal
import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import splitter

pub type Record(fields) {
  Record(codepoint_range: CodepointRange, fields: fields)
}

pub type CodepointRange {
  CodepointRange(from: UtfCodepoint, to: UtfCodepoint)
  SingleCodepoint(UtfCodepoint)
}

pub fn make_name_map(
  names names: String,
  codegen_src codegen_src: String,
) -> String {
  let names = parse_unidata(names)

  let if_ranges =
    list.filter_map(names, fn(record) {
      case record {
        Record(CodepointRange(from: start, to: end), [name, ..]) if name != "" -> {
          let start = internal.codepoint_to_hex(start)
          let end = internal.codepoint_to_hex(end)
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
          let cp = internal.codepoint_to_hex(cp)
          // TODO assert name is (uppercase letter + space + dash)
          let name = string.replace(in: name, each: "*", with: cp)
          // [0x0020, "SPACE"],
          Ok("[0x" <> cp <> ", \"" <> name <> "\"],\n")
        }
        Record(SingleCodepoint(_), _) -> Error(Nil)
        Record(CodepointRange(..), _) -> Error(Nil)
      }
    })
    |> string.concat()

  string.replace(in: codegen_src, each: "/*{{if_ranges}}*/", with: if_ranges)
  |> string.replace(each: "/*{{map_def}}*/", with: map_def)
}

pub fn parse_unidata(txt: String) -> List(Record(List(String))) {
  let line_end = splitter.new(["\n"])
  let comment = splitter.new(["#"])
  let separator = splitter.new([";"])
  let records = []

  use txt <- parse_unidata_loop(input: txt, output: records)
  let #(line, _, rest) = splitter.split(line_end, txt)
  let #(line, _, _) = splitter.split(comment, line)
  use <- bool.guard(when: string.is_empty(line), return: #(None, rest))
  let #(first_field, _, other_fields) = splitter.split(separator, line)
  let codepoint_range = parse_codepoint_range(first_field)
  let fields = string.split(other_fields, on: ";") |> list.map(string.trim)
  #(Some(Record(codepoint_range:, fields:)), rest)
}

fn parse_unidata_loop(
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
          parse_unidata_loop(rest, output:, with: line_parser)
        }
        #(None, rest) ->
          parse_unidata_loop(rest, output: records, with: line_parser)
      }
  }
}

fn parse_codepoint_range(str: String) -> CodepointRange {
  case string.split_once(str, on: "..") {
    Ok(#(start, end)) -> {
      let assert Ok(start) = string.trim(start) |> internal.parse_codepoint()
      let assert Ok(end) = string.trim(end) |> internal.parse_codepoint()
      CodepointRange(from: start, to: end)
    }
    Error(_) -> {
      let assert Ok(codepoint) = string.trim(str) |> internal.parse_codepoint()
      SingleCodepoint(codepoint)
    }
  }
}
