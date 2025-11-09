// Generated from https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedName.txt

import { int_to_hex } from "./codepoint.mjs";

export function get_name(cp) {
  let name = map.get(cp);
  if (name === undefined) {
    /*{{if_ranges}}*/ else {
      return "";
    }
  } else {
    return name;
  }
}

const map = new Map([
/*{{map_def}}*/
]);
