// Generated from https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt

import { Error, Ok, toList } from "../../gleam.mjs";
import { comparable_property } from "../internal.mjs";

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

const scripts = [
/*{{scripts}}*/
];

const list = /* @__PURE__ */ toList(scripts.map((record) => record[0]));

const map_short_to_long = /* @__PURE__ */ new Map(
  scripts.map((record) => [record[0], record[1]]),
);

const map_long_to_short = /* @__PURE__ */ new Map(
  scripts.map((record) => [comparable_property(record[1]), record[0]]),
);
