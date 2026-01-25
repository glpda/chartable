// Generated from:
// - https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt
// - https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedBidiClass.txt

import { Error, Ok } from "../../gleam.mjs";
import * as $bidi from "./bidi.mjs";

// Strong Types:
const L = new $bidi.LeftToRight();
const R = new $bidi.RightToLeft();
const AL = new $bidi.ArabicLetter();
// Weak Types:
const EN = new $bidi.EuropeanNumber();
const ES = new $bidi.EuropeanSeparator();
const ET = new $bidi.EuropeanTerminator();
const AN = new $bidi.ArabicNumber();
const CS = new $bidi.CommonSeparator();
const NSM = new $bidi.NonspacingMark();
const BN = new $bidi.BoundaryNeutral();
// Neutral Types:
const B = new $bidi.ParagraphSeparator();
const S = new $bidi.SegmentSeparator();
const WS = new $bidi.WhiteSpace();
const ON = new $bidi.OtherNeutral();
// Explicit Formatting Types:
const LRE = new $bidi.LeftToRightEmbedding();
const LRO = new $bidi.LeftToRightOverride();
const RLE = new $bidi.RightToLeftEmbedding();
const RLO = new $bidi.RightToLeftOverride();
const PDF = new $bidi.PopDirectionalFormat();
const LRI = new $bidi.LeftToRightIsolate();
const RLI = new $bidi.RightToLeftIsolate();
const FSI = new $bidi.FirstStrongIsolate();
const PDI = new $bidi.PopDirectionalIsolate();

export function codepoint_to_bidi_class(cp) {
  let left = 0, right = bidi_classes.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let record = bidi_classes[middle];
    if (cp < record[0]) {
      right = middle - 1;
    } else if (record[1] < cp) {
      left = middle + 1;
    } else {
      return new Ok(record[2]);
    }
  }
  left = 0, right = default_bidi_classes.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let record = default_bidi_classes[middle];
    if (cp < record[0]) {
      right = middle - 1;
    } else if (record[1] < cp) {
      left = middle + 1;
    } else {
      return new Ok(record[2]);
    }
  }
  return new Error(undefined);
}

const default_bidi_classes = [
/*{{default_bidi_classes}}*/
];

const bidi_classes = [
/*{{bidi_classes}}*/
];
