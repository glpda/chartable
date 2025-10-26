// Generated from {{data_source}}

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
/*{{math_records}}*/
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
