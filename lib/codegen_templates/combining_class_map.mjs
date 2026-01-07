// Generated from: https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt

export function codepoint_to_combining_class(cp) {
  let left = 0, right = combining_classes.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let record = combining_classes[middle];
    if (cp < record[0]) {
      right = middle - 1;
    } else if (record[1] < cp) {
      left = middle + 1;
    } else {
      return record[2];
    }
  }
  return 0;
}

const combining_classes = [
/*{{combining_classes}}*/
];
