import chartable/route.{type Route}
import chartable/unicode
import chartable/unicode/category
import chartable/unicode/codepoint.{type Codepoint}

import gleam/int
import gleam/list
import gleam/string

import lustre/attribute
import lustre/element/html

type Display {
  Character(String)
  Label(List(String))
  Surrogate
  PrivateUse
  Unassigned
}

pub fn tile(codepoint: Codepoint, route: Route) {
  let hex = codepoint.to_hex(codepoint)
  let #(class, display) = case display(codepoint) {
    Character(char) -> #("character", [html.text(char)])
    Label(label) -> #("label", case label {
      [] -> [html.text(hex)]
      _ -> list.map(label, html.text) |> list.intersperse(html.br([]))
    })
    PrivateUse -> #("private-use", [html.text("�")])
    Surrogate -> #("surrogate", [html.text("�")])
    Unassigned -> #("unassigned", [html.text("�")])
  }
  let url = route.codepoint_path(codepoint, route)
  html.a([attribute.href(url), attribute.class("tile")], [
    html.div([], [html.span([], [html.text("U+" <> hex)])]),
    html.div([], [html.span([attribute.class(class)], display)]),
  ])
}

fn display(codepoint: Codepoint) -> Display {
  let category = unicode.category_from_codepoint(codepoint)
  case category {
    category.Mark(_) ->
      case codepoint.to_int(codepoint) {
        cp if 0xFE00 <= cp && cp <= 0xFE0F ->
          Label(["VS" <> int.to_string(cp - 0xFE00 + 1)])
        cp if 0xE0100 <= cp && cp <= 0xE01EF ->
          Label(["VS" <> int.to_string(cp - 0xE0100 + 17)])
        0x13440 -> Label(["↔"])
        0x13447 -> Label(["▘"])
        0x13448 -> Label(["▖"])
        0x13449 -> Label(["▌"])
        0x1344A -> Label(["▝"])
        0x1344B -> Label(["▀"])
        0x1344C -> Label(["▞"])
        0x1344D -> Label(["▛"])
        0x1344E -> Label(["▗"])
        0x1344F -> Label(["▚"])
        0x13450 -> Label(["▄"])
        0x13451 -> Label(["▙"])
        0x13452 -> Label(["▐"])
        0x13453 -> Label(["▜"])
        0x13454 -> Label(["▟"])
        0x13455 -> Label(["█"])
        _ -> Character("◌" <> unsafe_codepoint_to_string(codepoint))
      }
    category.Separator(category.SpaceSeparator) ->
      Label(case codepoint.to_int(codepoint) {
        0x0020 -> ["SP"]
        0x00A0 -> ["NB", "SP"]
        0x2000 -> ["NQ", "SP"]
        0x2001 -> ["MQ", "SP"]
        0x2002 -> ["EN", "SP"]
        0x2003 -> ["EM", "SP"]
        0x2004 -> ["3/M", "SP"]
        0x2005 -> ["4/M", "SP"]
        0x2006 -> ["6/M", "SP"]
        0x2007 -> ["F", "SP"]
        0x2008 -> ["P", "SP"]
        0x2009 -> ["TH", "SP"]
        0x200A -> ["H", "SP"]
        0x202F -> ["NNB", "SP"]
        0x205F -> ["MM", "SP"]
        0x3000 -> ["ID", "SP"]
        _ -> []
      })
    category.Separator(category.LineSeparator) -> Label(["L", "SEP"])
    category.Separator(category.ParagraphSeparator) -> Label(["P", "SEP"])
    category.Other(category.Control) ->
      Label(case codepoint.to_int(codepoint) {
        0x0000 -> ["NUL"]
        0x0001 -> ["SOH"]
        0x0002 -> ["STX"]
        0x0003 -> ["ETX"]
        0x0004 -> ["EOT"]
        0x0005 -> ["ENQ"]
        0x0006 -> ["ACK"]
        0x0007 -> ["BEL"]
        0x0008 -> ["BS"]
        0x0009 -> ["HT"]
        0x000A -> ["LF"]
        0x000B -> ["VT"]
        0x000C -> ["FF"]
        0x000D -> ["CR"]
        0x000E -> ["SO"]
        0x000F -> ["SI"]
        0x0010 -> ["DLE"]
        0x0011 -> ["DC1"]
        0x0012 -> ["DC2"]
        0x0013 -> ["DC3"]
        0x0014 -> ["DC4"]
        0x0015 -> ["NAK"]
        0x0016 -> ["SYN"]
        0x0017 -> ["ETB"]
        0x0018 -> ["CAN"]
        0x0019 -> ["EM"]
        0x001A -> ["SUB"]
        0x001B -> ["ESC"]
        0x001C -> ["FS"]
        0x001D -> ["GS"]
        0x001E -> ["RS"]
        0x001F -> ["US"]
        0x007F -> ["DEL"]
        0x0080 -> ["PAD"]
        0x0081 -> ["HOP"]
        0x0082 -> ["BPH"]
        0x0083 -> ["NBH"]
        0x0084 -> ["IND"]
        0x0085 -> ["NEL"]
        0x0086 -> ["SSA"]
        0x0087 -> ["ESA"]
        0x0088 -> ["HTS"]
        0x0089 -> ["HTJ"]
        0x008A -> ["VTS"]
        0x008B -> ["PLD"]
        0x008C -> ["PLU"]
        0x008D -> ["RI"]
        0x008E -> ["SS2"]
        0x008F -> ["SS3"]
        0x0090 -> ["DCS"]
        0x0091 -> ["PU1"]
        0x0092 -> ["PU2"]
        0x0093 -> ["STS"]
        0x0094 -> ["CCH"]
        0x0095 -> ["MW"]
        0x0096 -> ["SPA"]
        0x0097 -> ["EPA"]
        0x0098 -> ["SOS"]
        0x0099 -> ["SGC"]
        0x009A -> ["SCI"]
        0x009B -> ["CSI"]
        0x009C -> ["ST"]
        0x009D -> ["OSC"]
        0x009E -> ["PM"]
        0x009F -> ["APC"]
        cp -> ["control-" <> codepoint.int_to_hex(cp)]
      })

    category.Other(category.Format) ->
      Label(case codepoint.to_int(codepoint) {
        0x00AD -> ["SHY"]
        0x061C -> ["ALM"]
        cp if 0x0600 <= cp && cp <= 0x06FF -> [
          unsafe_codepoint_to_string(codepoint),
        ]
        0x070F -> ["SAM"]
        0x08E2 -> ["\u{08E2}"]
        0x180E -> ["MVS"]
        0x200B -> ["ZW", "SP"]
        0x200C -> ["ZW", "NJ"]
        0x200D -> ["ZW", "J"]
        0x200E -> ["LRM"]
        0x200F -> ["RLM"]
        0x202A -> ["LRE"]
        0x202B -> ["RLE"]
        0x202C -> ["PDF"]
        0x202D -> ["LRO"]
        0x202E -> ["RLO"]
        0x2060 -> ["WJ"]
        0x2061 -> ["f₍₎"]
        0x2062 -> ["×"]
        0x2063 -> [","]
        0x2064 -> ["+"]
        0x2066 -> ["LRI"]
        0x2067 -> ["RLI"]
        0x2068 -> ["FSI"]
        0x2069 -> ["PDI"]
        0x206A -> ["I", "SS"]
        0x206B -> ["A", "SS"]
        0x206C -> ["I", "AFS"]
        0x206D -> ["A", "AFS"]
        0x206E -> ["NA", "DS"]
        0x206F -> ["NO", "DS"]
        0xFEFF -> ["BOM"]
        // 0xFEFF -> "ZW NBSP"
        0xFFF9 -> ["I A A"]
        0xFFFA -> ["I A S"]
        0xFFFB -> ["I A T"]
        0xFFFC -> ["OBJ"]
        0x110BD -> ["\u{110BC}"]
        0x110CD -> ["\u{110BC}"]
        // NOTE: could also use: ⿽ ⿹ ⿺ ⿸ ⿴ ⿶ ⿵ ⿾
        0x13430 -> [":"]
        0x13431 -> ["*"]
        0x13432 -> ["◰"]
        0x13433 -> ["◱"]
        0x13434 -> ["◳"]
        0x13435 -> ["◲"]
        0x13436 -> ["+"]
        0x13437 -> ["("]
        0x13438 -> [")"]
        0x13439 -> ["▣"]
        0x1343A -> ["⊔"]
        0x1343B -> ["⊓"]
        0x1343C -> ["["]
        0x1343D -> ["]"]
        0x1343E -> ["⹗"]
        0x1343F -> ["⹘"]
        0x1BCA0 -> ["⇸"]
        0x1BCA1 -> ["↳"]
        0x1BCA2 -> ["↓"]
        0x1BCA3 -> ["↑"]
        0x1D173 -> ["BEGIN", "BEAM"]
        0x1D174 -> ["END", "BEAM"]
        0x1D175 -> ["BEGIN", "TIE"]
        0x1D176 -> ["END", "TIE"]
        0x1D177 -> ["BEGIN", "SLUR"]
        0x1D178 -> ["END", "SLUR"]
        0x1D179 -> ["BEGIN", "PHR."]
        0x1D17A -> ["END", "PHR."]
        0xE0001 -> ["BEGIN"]
        cp if 0xE0020 <= cp && cp <= 0xE007E -> {
          let assert Ok(utf) = string.utf_codepoint(cp - 0xE0000)
          [string.from_utf_codepoints([utf])]
        }
        0xE007F -> ["END"]
        cp -> ["format-" <> codepoint.int_to_hex(cp)]
      })
    category.Other(category.PrivateUse) -> PrivateUse
    category.Other(category.Surrogate) -> Surrogate
    category.Other(category.Unassigned) -> Unassigned
    _ ->
      case codepoint.to_int(codepoint) {
        0x13441 -> Label(["FB"])
        0x13442 -> Label(["HB"])
        0x13443 -> Label(["■"])
        0x13444 -> Label(["▪"])
        0x13445 -> Label(["▮"])
        0x13446 -> Label(["▬"])
        0x1D159 -> Label(["NULL", "NOTE", "HEAD"])
        _ -> Character(unsafe_codepoint_to_string(codepoint))
      }
  }
}

/// Will panic for surrogate code points!
fn unsafe_codepoint_to_string(codepoint: Codepoint) {
  let assert Ok(utf) = codepoint.to_utf(codepoint)
  string.from_utf_codepoints([utf])
}
