// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Regular_expressions/Unicode_character_class_escape

import * as $category from "./category.mjs";
import { utf_codepoint_to_int } from "../../../gleam_stdlib/gleam/string.mjs";

const uppercase_letter = /\p{Lu}/u;
const lowercase_letter = /\p{Ll}/u;
const titlecase_letter = /\p{Lt}/u;
const modifier_letter = /\p{Lm}/u;
const other_letter = /\p{Lo}/u;

const nonspacing_mark = /\p{Mn}/u;
const spacing_mark = /\p{Mc}/u;
const enclosing_mark = /\p{Me}/u;

const decimal_number = /\p{Nd}/u;
const letter_number = /\p{Nl}/u;
const other_number = /\p{No}/u;

const connector_punctuation = /\p{Pc}/u;
const dash_punctuation = /\p{Pd}/u;
const open_punctuation = /\p{Ps}/u;
const close_punctuation = /\p{Pe}/u;
const initial_punctuation = /\p{Pi}/u;
const final_punctuation = /\p{Pf}/u;
const other_punctuation = /\p{Po}/u;

const math_symbol = /\p{Sm}/u;
const currency_symbol = /\p{Sc}/u;
const modifier_symbol = /\p{Sk}/u;
const other_symbol = /\p{So}/u;

const space_separator = /\p{Zs}/u;
const format = /\p{Cf}/u;

export function get_category(cp) {
  let cp_int = utf_codepoint_to_int(cp)
  let cp_str = String.fromCharCode(cp_int);
  if (lowercase_letter.test(cp_str)) {
    return new $category.LetterLowercase();
  } else if (uppercase_letter.test(cp_str)) {
    return new $category.LetterUppercase();
  } else if (titlecase_letter.test(cp_str)) {
    return new $category.LetterTitlecase();
  } else if (modifier_letter.test(cp_str)) {
    return new $category.LetterModifier();
  } else if (other_letter.test(cp_str)) {
    return new $category.LetterOther();
  } else if (nonspacing_mark.test(cp_str)) {
    return new $category.MarkNonspacing();
  } else if (spacing_mark.test(cp_str)) {
    return new $category.MarkSpacing();
  } else if (enclosing_mark.test(cp_str)) {
    return new $category.MarkEnclosing();
  } else if (decimal_number.test(cp_str)) {
    return new $category.NumberDecimal();
  } else if (letter_number.test(cp_str)) {
    return new $category.NumberLetter();
  } else if (other_number.test(cp_str)) {
    return new $category.NumberOther();
  } else if (connector_punctuation.test(cp_str)) {
    return new $category.PunctuationConnector();
  } else if (dash_punctuation.test(cp_str)) {
    return new $category.PunctuationDash();
  } else if (open_punctuation.test(cp_str)) {
    return new $category.PunctuationOpen();
  } else if (close_punctuation.test(cp_str)) {
    return new $category.PunctuationClose();
  } else if (initial_punctuation.test(cp_str)) {
    return new $category.PunctuationInitial();
  } else if (final_punctuation.test(cp_str)) {
    return new $category.PunctuationFinal();
  } else if (other_punctuation.test(cp_str)) {
    return new $category.PunctuationOther();
  } else if (math_symbol.test(cp_str)) {
    return new $category.SymbolMath();
  } else if (currency_symbol.test(cp_str)) {
    return new $category.SymbolCurrency();
  } else if (modifier_symbol.test(cp_str)) {
    return new $category.SymbolModifier();
  } else if (other_symbol.test(cp_str)) {
    return new $category.SymbolOther();
  } else if (space_separator.test(cp_str)) {
    return new $category.SeparatorSpace();
  } else if (cp_int === 0x2028) {
    return new $category.SeparatorLine();
  } else if (cp_int === 0x2029) {
    return new $category.SeparatorParagraph();
  } else if ((0x0000 <= cp_int) && (cp_int <= 0x001F)) {
    return new $category.Control();
  } else if ((0x007F <= cp_int) && (cp_int <= 0x009F)) {
    return new $category.Control();
  } else if (format.test(cp_str)) {
    return new $category.Format();
  } else if ((0xE000 <= cp_int) && (cp_int <= 0xF8FF)) {
    return new $category.PrivateUse();
  } else if ((0xF0000 <= cp_int) && (cp_int <= 0xFFFFD)) {
    return new $category.PrivateUse();
  } else if ((0x100000 <= cp_int) && (cp_int <= 0x10FFFD)) {
    return new $category.PrivateUse();
  } else {
    return new $category.Unassigned();
  }
}
