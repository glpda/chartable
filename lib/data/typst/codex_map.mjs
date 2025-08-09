// Generated from {{data_source}}

import { Ok, Error, toList } from "../../gleam.mjs";

export function codepoint_to_notations(codepoint) {
  let notations = map_codepoint_to_notations.get(codepoint);
  if (notations === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(toList(notations));
  }
}

export function notation_to_codepoints(notation) {
  let codepoints = map_notation_to_codepoints.get(notation);
  if (codepoints === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(toList(codepoints));
  }
}

const map_codepoint_to_notations = new Map([
/*{{codepoint_to_notations}}*/
])

const map_notation_to_codepoints = new Map([
/*{{notation_to_codepoints}}*/
])
