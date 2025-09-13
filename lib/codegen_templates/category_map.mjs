// Generated from https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedGeneralCategory.txt

import * as $category from "./category.mjs";

// Letters:
const Lu = new $category.Letter(new $category.UppercaseLetter());
const Ll = new $category.Letter(new $category.LowercaseLetter());
const Lt = new $category.Letter(new $category.TitlecaseLetter());
const Lm = new $category.Letter(new $category.ModifierLetter());
const Lo = new $category.Letter(new $category.OtherLetter());
// Marks:
const Mn = new $category.Mark(new $category.NonspacingMark());
const Mc = new $category.Mark(new $category.SpacingMark());
const Me = new $category.Mark(new $category.EnclosingMark());
// Numbers:
const Nd = new $category.Number(new $category.DecimalNumber());
const Nl = new $category.Number(new $category.LetterNumber());
const No = new $category.Number(new $category.OtherNumber());
// Punctuations:
const Pc = new $category.Punctuation(new $category.ConnectorPunctuation());
const Pd = new $category.Punctuation(new $category.DashPunctuation());
const Ps = new $category.Punctuation(new $category.OpenPunctuation());
const Pe = new $category.Punctuation(new $category.ClosePunctuation());
const Pi = new $category.Punctuation(new $category.InitialPunctuation());
const Pf = new $category.Punctuation(new $category.FinalPunctuation());
const Po = new $category.Punctuation(new $category.OtherPunctuation());
// Symbols:
const Sm = new $category.Symbol(new $category.MathSymbol());
const Sc = new $category.Symbol(new $category.CurrencySymbol());
const Sk = new $category.Symbol(new $category.ModifierSymbol());
const So = new $category.Symbol(new $category.OtherSymbol());
// Separators:
const Zs = new $category.Separator(new $category.SpaceSeparator());
const Zl = new $category.Separator(new $category.LineSeparator());
const Zp = new $category.Separator(new $category.ParagraphSeparator());
// Others:
const Cc = new $category.Other(new $category.Control());
const Cf = new $category.Other(new $category.Format());
const Cs = new $category.Other(new $category.Surrogate());
const Co = new $category.Other(new $category.PrivateUse());
const Cn = new $category.Other(new $category.Unassigned());

export function codepoint_to_category(cp) {
  let left = 0, right = categories.length - 1;
  while (left <= right) {
    let middle = (right + left) >> 1; // Math.floor((right + left) / 2);
    let record = categories[middle];
    if (cp < record[0]) {
      right = middle - 1;
    } else if (record[1] < cp) {
      left = middle + 1;
    } else if (record.length === 3) {
      return record[2];
    // record.length === 4 (alternating record)
    } else if (cp % 2 === 0) { // even
      return record[2];
    } else { // odd
      return record[3];
    }
  }
  return Cn;
}

const categories = [
/*{{categories}}*/
];
