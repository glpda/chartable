// Generated from {{data_source}}

import { Ok, Error, toList } from "../../gleam.mjs";

export function grapheme_to_notations(grapheme) {
  let notations = map_grapheme_to_notations.get(grapheme);
  if (notations === undefined) {
    return new toList([]);
  } else {
    return new toList(notations);
  }
}

export function notation_to_grapheme(notation) {
  let grapheme = map_notation_to_grapheme.get(notation);
  if (grapheme === undefined) {
    return new Error(undefined);
  } else {
    return new Ok(grapheme);
  }
}

const map_grapheme_to_notations = new Map([
/*{{grapheme_to_notations}}*/
])

const map_notation_to_grapheme = new Map([
/*{{notation_to_grapheme}}*/
])
