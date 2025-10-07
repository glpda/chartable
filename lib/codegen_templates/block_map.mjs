// Generated from:
// - https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt
// - https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt

import { Error, Ok, toList } from "../../gleam.mjs";
import { comparable_property } from "../../chartable.mjs";

export function codepoint_to_block(cp) {
  let left = 0, right = blocks.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let [start, end, name, ...aliases] = blocks[middle];
    if (cp < start) {
      right = middle - 1;
    } else if (end < cp) {
      left = middle + 1;
    } else {
      return new Ok([start, end, name, toList(aliases)]);
    }
  }
  return new Error(undefined);
}

export function name_to_block(name) {
  let index = map.get(name);
  if (index === undefined) {
    return new Error(undefined);
  } else {
    let [start, end, name, ...aliases] = blocks[index];
    return new Ok([start, end, name, toList(aliases)]);
  }
}

export function get_list() {
  return toList(blocks.map((record) => {
    let [start, end, name, ...aliases] = record;
    return [start, end, name, toList(aliases)];
  }));
}

const blocks = [
/*{{blocks}}*/
];

const map = /* @__PURE__ */ new Map(
  blocks.flatMap((record, index) =>
    record.slice(2).map((name) => [comparable_property(name), index])
  ),
);
