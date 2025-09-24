// Generated from {{data_source}}

import { Error, Ok, toList } from "../../gleam.mjs";

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

const notation_table = [
/*{{notation_table}}*/
];

const map_grapheme_to_notations = new Map(
  notation_table.map((record) => [record[0], record.slice(1)]),
);

const map_notation_to_grapheme = new Map(
  notation_table.flatMap((record) =>
    record.slice(1).map((notation) => [notation, record[0]])
  ),
);
