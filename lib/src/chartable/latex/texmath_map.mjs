// Generated from https://mirrors.ctan.org/info/impatient/book.pdf

import { Error, Ok, toList } from "../../gleam.mjs";
import * as $mathtype from "./math_type.mjs";

const ORD = new $mathtype.Ordinary();
const ABC = new $mathtype.Alphabetic();
const ACC = new $mathtype.Accent();
const ACW = new $mathtype.AcentWide();
const BOT = new $mathtype.BottomAccent();
const BOW = new $mathtype.BottomAccentWide();
const LAY = new $mathtype.AccentOverlay();
const BIN = new $mathtype.BinaryOperation();
const REL = new $mathtype.Relation();
const LOP = new $mathtype.LargeOperator();
const RAD = new $mathtype.Radical();
const OPN = new $mathtype.Opening();
const CLO = new $mathtype.Closing();
const FEN = new $mathtype.Fencing();
const OVR = new $mathtype.Over();
const NDR = new $mathtype.Under();
const PUN = new $mathtype.Punctuation();

export function codepoint_to_notations(codepoint) {
  let notations = map_codepoint_to_notations.get(codepoint);
  if (notations === undefined) {
    return new toList([]);
  } else {
    return new toList(notations);
  }
}

export function notation_to_mathtype_codepoint(notation) {
  let codepoint_type = map_notation_to_mathtype_codepoint.get(notation);
  if (codepoint_type === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(codepoint_type);
  }
}

const math_records = [
[0x221E, ORD, "infty"],
[0x2220, ORD, "angle"],
[0x25B3, ORD, "triangle"],
[0x2205, ORD, "emptyset"],
[0x22A5, ORD, "bot"],
[0x22A4, ORD, "top"],
[0x2203, ORD, "exists"],
[0x2200, ORD, "forall"],
[0x2207, ORD, "nabla"],
[0x00AC, ORD, "neg"],
[0x00AC, ORD, "lnot"],
[0x2032, ORD, "prime"],
[0x2202, ORD, "partial"],
[0x221A, ORD, "surd"],
[0x2118, ORD, "wp"],
[0x266D, ORD, "flat"],
[0x266F, ORD, "sharp"],
[0x266E, ORD, "natural"],
[0x2663, ORD, "clubsuit"],
[0x2662, ORD, "diamondsuit"],
[0x2661, ORD, "heartsuit"],
[0x2660, ORD, "spadesuit"],
[0x211C, ABC, "Re"],
[0x2111, ABC, "Im"],
[0x0127, ABC, "hbar"],
[0x2113, ABC, "ell"],
[0x2135, ABC, "aleph"],
[0x1D6A4, ABC, "imath"],
[0x1D6A5, ABC, "jmath"],
[0x03B1, ABC, "alpha"],
[0x03B2, ABC, "beta"],
[0x03C7, ABC, "chi"],
[0x03B4, ABC, "delta"],
[0x0394, ABC, "Delta"],
[0x03F5, ABC, "epsilon"],
[0x03B5, ABC, "varepsilon"],
[0x03B7, ABC, "eta"],
[0x03B3, ABC, "gamma"],
[0x0393, ABC, "Gamma"],
[0x03B9, ABC, "iota"],
[0x03BA, ABC, "kappa"],
[0x03BB, ABC, "lambda"],
[0x039B, ABC, "Lambda"],
[0x03BC, ABC, "mu"],
[0x03BD, ABC, "nu"],
[0x03C9, ABC, "omega"],
[0x03A9, ABC, "Omega"],
[0x03D5, ABC, "phi"],
[0x03C6, ABC, "varphi"],
[0x03A6, ABC, "Phi"],
[0x03C0, ABC, "pi"],
[0x03D6, ABC, "varpi"],
[0x03A0, ABC, "Pi"],
[0x03C8, ABC, "psi"],
[0x03A8, ABC, "Psi"],
[0x03C1, ABC, "rho"],
[0x03F1, ABC, "varrho"],
[0x03C3, ABC, "sigma"],
[0x03C2, ABC, "varsigma"],
[0x03A3, ABC, "Sigma"],
[0x03C4, ABC, "tau"],
[0x03B8, ABC, "theta"],
[0x03D1, ABC, "vartheta"],
[0x0398, ABC, "Theta"],
[0x03C5, ABC, "upsilon"],
[0x03A5, ABC, "Upsilon"],
[0x03BE, ABC, "xi"],
[0x039E, ABC, "Xi"],
[0x03B6, ABC, "zeta"],
[0x2228, BIN, "vee"],
[0x2228, BIN, "lor"],
[0x2227, BIN, "wedge"],
[0x2227, BIN, "land"],
[0x2A3F, BIN, "amalg"],
[0x2229, BIN, "cap"],
[0x222A, BIN, "cup"],
[0x228E, BIN, "uplus"],
[0x2293, BIN, "sqcap"],
[0x2294, BIN, "sqcup"],
[0x2020, BIN, "dagger"],
[0x2021, BIN, "ddagger"],
[0x22C5, BIN, "cdot"],
[0x22C4, BIN, "diamond"],
[0x2022, BIN, "bullet"],
[0x2218, BIN, "circ"],
[0x25CB, BIN, "bigcirc"],
[0x2299, BIN, "odot"],
[0x2296, BIN, "ominus"],
[0x2295, BIN, "oplus"],
[0x2298, BIN, "oslash"],
[0x2297, BIN, "otimes"],
[0x00B1, BIN, "pm"],
[0x2213, BIN, "mp"],
[0x25C1, BIN, "triangleleft"],
[0x25B7, BIN, "triangleright"],
[0x25BF, BIN, "triangledown"],
[0x25B5, BIN, "triangleup"],
[0x2217, BIN, "ast"],
[0x22C6, BIN, "star"],
[0x00D7, BIN, "times"],
[0x00F7, BIN, "div"],
[0x2216, BIN, "setminus"],
[0x2240, BIN, "wr"],
[0x224D, REL, "asymp"],
[0x2245, REL, "cong"],
[0x22A3, REL, "dashv"],
[0x22A2, REL, "vdash"],
[0x27C2, REL, "perp"],
[0x2223, REL, "mid"],
[0x2225, REL, "parallel"],
[0x2250, REL, "doteq"],
[0x2261, REL, "equiv"],
[0x2265, REL, "ge"],
[0x2265, REL, "geq"],
[0x2264, REL, "le"],
[0x2264, REL, "leq"],
[0x226B, REL, "gg"],
[0x226A, REL, "ll"],
[0x22A7, REL, "models"],
[0x2260, REL, "ne"],
[0x2260, REL, "neq"],
[0x2209, REL, "notin"],
[0x2208, REL, "in"],
[0x220B, REL, "ni"],
[0x220B, REL, "owns"],
[0x227A, REL, "prec"],
[0x2AAF, REL, "preceq"],
[0x227B, REL, "succ"],
[0x2AB0, REL, "succeq"],
[0x22C8, REL, "bowtie"],
[0x221D, REL, "propto"],
[0x2248, REL, "approx"],
[0x223C, REL, "sim"],
[0x2243, REL, "simeq"],
[0x2322, REL, "frown"],
[0x2323, REL, "smile"],
[0x2282, REL, "subset"],
[0x2286, REL, "subseteq"],
[0x2283, REL, "supset"],
[0x2287, REL, "supseteq"],
[0x2291, REL, "sqsubseteq"],
[0x2292, REL, "sqsupseteq"],
[0x2190, REL, "leftarrow"],
[0x2190, REL, "gets"],
[0x21D0, REL, "Leftarrow"],
[0x2192, REL, "rightarrow"],
[0x2192, REL, "to"],
[0x21D2, REL, "Rightarrow"],
[0x2194, REL, "leftrightarrow"],
[0x21D4, REL, "Leftrightarrow"],
[0x27F5, REL, "longleftarrow"],
[0x27F8, REL, "Longleftarrow"],
[0x27F6, REL, "longrightarrow"],
[0x27F9, REL, "Longrightarrow"],
[0x27F7, REL, "longleftrightarrow"],
[0x27FA, REL, "Longleftrightarrow"],
[0x27FA, REL, "iff"],
[0x21A9, REL, "hookleftarrow"],
[0x21AA, REL, "hookrightarrow"],
[0x21BD, REL, "leftharpoondown"],
[0x21C1, REL, "rightharpoondown"],
[0x21BC, REL, "leftharpoonup"],
[0x21C0, REL, "rightharpoonup"],
[0x21CC, REL, "rightleftharpoons"],
[0x21A6, REL, "mapsto"],
[0x27FC, REL, "longmapsto"],
[0x2193, REL, "downarrow"],
[0x21D3, REL, "Downarrow"],
[0x2191, REL, "uparrow"],
[0x21D1, REL, "Uparrow"],
[0x2195, REL, "updownarrow"],
[0x21D5, REL, "Updownarrow"],
[0x2197, REL, "nearrow"],
[0x2198, REL, "searrow"],
[0x2196, REL, "nwarrow"],
[0x2199, REL, "swarrow"],
[0x007B, OPN, "lbrace"],
[0x007B, OPN, "{"],
[0x007D, CLO, "rbrace"],
[0x007D, CLO, "}"],
[0x005B, OPN, "lbrack"],
[0x005D, CLO, "rbrack"],
[0x27E8, OPN, "langle"],
[0x27E9, CLO, "rangle"],
[0x2308, OPN, "lceil"],
[0x2309, CLO, "rceil"],
[0x230A, OPN, "lfloor"],
[0x230B, CLO, "rfloor"],
[0x005C, FEN, "backslash"],
[0x007C, FEN, "vert"],
[0x2016, FEN, "Vert"],
[0x2016, FEN, "|"],
[0x27EE, OPN, "lgroup"],
[0x27EF, CLO, "rgroup"],
[0x22C2, LOP, "bigcap"],
[0x22C3, LOP, "bigcup"],
[0x2A00, LOP, "bigodot"],
[0x2A01, LOP, "bigoplus"],
[0x2A02, LOP, "bigotimes"],
[0x2A06, LOP, "bigsqcup"],
[0x2A04, LOP, "biguplus"],
[0x22C1, LOP, "bigvee"],
[0x22C0, LOP, "bigwedge"],
[0x2210, LOP, "coprod"],
[0x222B, LOP, "smallint"],
[0x222B, LOP, "int"],
[0x222E, LOP, "oint"],
[0x220F, LOP, "prod"],
[0x2211, LOP, "sum"],
[0x00B7, PUN, "cdotp"],
[0x002E, PUN, "ldotp"],
[0x003A, PUN, "colon"],
[0x2026, PUN, "ldots"],
[0x22EF, PUN, "cdots"],
[0x22EE, PUN, "vdots"],
[0x22F1, PUN, "ddots"],
[0x221A, RAD, "sqrt"],
[0x23B0, FEN, "lmoustache"],
[0x23B1, FEN, "rmoustache"],
[0x23AA, FEN, "bracevert"]
];

function make_map_codepoint_to_notations(records) {
  const map = new Map();
  for (const record of records) {
    let notations = map.get(record[0]);
    if (notations === undefined) {
      map.set(record[0], [record[2]]);
    } else {
      map.set(record[0], [...notations, record[2]]);
    }
  }
  return map;
}

const map_codepoint_to_notations = make_map_codepoint_to_notations(
  math_records,
);

const map_notation_to_mathtype_codepoint = new Map(
  math_records.map((record) => [record[2], [record[1], record[0]]]),
);
