// Generated from: https://www.unicode.org/Public/UCD/latest/ucd/NameAliases.txt

import { List$Empty, toList } from "../../gleam.mjs";

export function get_aliases(cp) {
  let aliases = map.get(cp);
  if (aliases === undefined) {
    return [
      List$Empty(), // corrections
      List$Empty(), // controls
      List$Empty(), // alternates
      List$Empty(), // figments
      List$Empty(), // abbreviations
    ];
  } else {
    return aliases;
  }
}

const name_aliases = [
// [0xC0DE, [corrections], [controls], [alternates], [figments], [abbreviations]],
/*{{name_aliases}}*/
];

const map = /* @__PURE__ */ new Map(
  name_aliases.map((record) =>
    [record[0], record.slice(1).map((aliases) => toList(aliases))]
  )
);
