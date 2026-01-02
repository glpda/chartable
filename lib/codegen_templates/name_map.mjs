// Generated from https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt

export function get_name(cp) {
  let name = map.get(cp);
  if (name === undefined) {
    return "";
  } else {
    return name;
  }
}

const map = new Map([
/*{{map_def}}*/
]);
