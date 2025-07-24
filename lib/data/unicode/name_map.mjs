// Generated from https://www.unicode.org/Public/UNIDATA/extracted/DerivedName.txt

import { to_base16 } from "../../../gleam_stdlib/gleam/int.mjs";
import { pad_start } from "../../../gleam_stdlib/gleam/string.mjs";
import { Ok, Error } from "../../gleam.mjs";

function display_codepoint(cp) {
  return pad_start(to_base16(cp), 4, "0");
}

export function get_name(cp) {
  /*{{if_ranges}}*/{
    let name = map.get(cp);
    if (name === undefined) {
      return new Error(undefined);
    } else {
      return new Ok(name);
    }
  }
}

const map = new Map([
/*{{map_def}}*/])
