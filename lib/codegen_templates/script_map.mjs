// Generated from:
// - https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt
// - https://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt

import { Error, Ok, toList } from "../../gleam.mjs";
import { comparable_property } from "../../chartable.mjs";

export function get_list() {
  return list;
}

export function short_name_to_long_name(short) {
  let long = map_short_to_long.get(short);
  if (long === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(long);
  }
}

export function long_name_to_short_name(long) {
  let short = map_long_to_short.get(long);
  if (short === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(short);
  }
}

export function codepoint_to_script(cp) {
  let left = 0, right = script_ranges.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let script_range = script_ranges[middle];
    if (cp < script_range[0]) {
      right = middle - 1;
    } else if (script_range[1] < cp) {
      left = middle + 1;
    } else {
      return script_range[2];
    }
  }
  return "zzzz"; // Unknown
}

export function script_to_ranges(script) {
  return toList(
    script_ranges
      .filter((script_range) => script_range[2] === script)
      .map((script_range) => script_range.slice(0, 2)),
  );
}

const script_names = [
/*{{script_names}}*/
];

const list = /* @__PURE__ */ toList(script_names.map((record) => record[0]));

const map_short_to_long = /* @__PURE__ */ new Map(
  script_names.map((record) => [record[0], record[1]]),
);

const map_long_to_short = /* @__PURE__ */ new Map(
  script_names.map((record) => [comparable_property(record[1]), record[0]]),
);

const script_ranges = [
/*{{script_ranges}}*/
];
