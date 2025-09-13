// Generated from https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedGeneralCategory.txt

import * as $category from "./category.mjs";

// Letters:
const Lu = new $category.LetterUppercase();
const Ll = new $category.LetterLowercase();
const Lt = new $category.LetterTitlecase();
const Lm = new $category.LetterModifier();
const Lo = new $category.LetterOther();
// Marks:
const Mn = new $category.MarkNonspacing();
const Mc = new $category.MarkSpacing();
const Me = new $category.MarkEnclosing();
// Numbers:
const Nd = new $category.NumberDecimal();
const Nl = new $category.NumberLetter();
const No = new $category.NumberOther();
// Punctuations:
const Pc = new $category.PunctuationConnector();
const Pd = new $category.PunctuationDash();
const Ps = new $category.PunctuationOpen();
const Pe = new $category.PunctuationClose();
const Pi = new $category.PunctuationInitial();
const Pf = new $category.PunctuationFinal();
const Po = new $category.PunctuationOther();
// Symbols:
const Sm = new $category.SymbolMath();
const Sc = new $category.SymbolCurrency();
const Sk = new $category.SymbolModifier();
const So = new $category.SymbolOther();
// Separators:
const Zs = new $category.SeparatorSpace();
const Zl = new $category.SeparatorLine();
const Zp = new $category.SeparatorParagraph();
// Others:
const Cc = new $category.Control();
const Cf = new $category.Format();
const Cs = new $category.Surrogate();
const Co = new $category.PrivateUse();
const Cn = new $category.Unassigned();

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
