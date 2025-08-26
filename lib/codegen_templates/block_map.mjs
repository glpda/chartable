// Generated from https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt

import { Error, Ok, toList } from "../../gleam.mjs";
import { comparable_property } from "../internal.mjs";

export function codepoint_to_block(cp) {
  let left = 0, right = blocks.length;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let record = blocks[middle];
    if (cp < record[0][0]) {
      right = middle - 1;
    } else if (record[0][1] < cp) {
      left = middle + 1;
    } else {
      return record[1];
    }
  }
  return "No_Block";
}

export function block_to_codepoint_pair(block) {
  let pair = map.get(block);
  if (pair === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(pair);
  }
}

export function get_list() {
  return list;
}

const blocks = [
/*{{blocks}}*/
];

const list = /* @__PURE__ */ toList(blocks.map((record) => record[1]));

const map = /* @__PURE__ */ new Map(
  blocks.map((record) => [comparable_property(record[1]), record[0]]),
);
