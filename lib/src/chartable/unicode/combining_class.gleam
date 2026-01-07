//// The [Canonical Combining Class](https://www.unicode.org/reports/tr44/#Canonical_Combining_Class_Values)
//// indicates the priority with wich a combining character is attached to its
//// base character.
////
//// These values are used in the "Canonical Ordering Algorithm".

import chartable
import gleam/int

pub opaque type CombiningClass {
  Ccc(value: Int)
}

// pub const not_reordered = Ccc(0)

/// Converts an integer to a [`CombiningClass`](#CombiningClass),
/// skipping boundary checks.
///
/// Only call on integer between `0` and `254`!
@internal
pub fn unsafe(value: Int) -> CombiningClass {
  Ccc(value:)
}

/// Converts an integer to a [`CombiningClass`](#CombiningClass) value.
///
/// Returns an `Error` if the integer is not between `0` and `254`.
pub fn from_int(value: Int) -> Result(CombiningClass, Nil) {
  case value {
    i if 0 <= i && i <= 254 -> Ok(Ccc(i))
    _ -> Error(Nil)
  }
}

/// Converts a name `String` to a [`CombiningClass`](#CombiningClass) value,
/// combining class name matching follows rule
/// [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3)
/// (ignore case, whitespaces, underscores, hyphens, and initial prefix "is").
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(not_reordered) = combining_class.from_name("not reordered")
/// assert combining_class.from_name("NR") == Ok(not_reordered)
/// ```
///
pub fn from_name(name: String) -> Result(CombiningClass, Nil) {
  case chartable.comparable_property(name) {
    "nr" -> Ok(Ccc(000))
    "ov" -> Ok(Ccc(001))
    "hanr" -> Ok(Ccc(006))
    "nk" -> Ok(Ccc(007))
    "kv" -> Ok(Ccc(008))
    "vr" -> Ok(Ccc(009))
    "atbl" -> Ok(Ccc(200))
    "atb" -> Ok(Ccc(202))
    "ata" -> Ok(Ccc(214))
    "atar" -> Ok(Ccc(216))
    "bl" -> Ok(Ccc(218))
    "b" -> Ok(Ccc(220))
    "br" -> Ok(Ccc(222))
    "l" -> Ok(Ccc(224))
    "r" -> Ok(Ccc(226))
    "al" -> Ok(Ccc(228))
    "a" -> Ok(Ccc(230))
    "ar" -> Ok(Ccc(232))
    "db" -> Ok(Ccc(233))
    "da" -> Ok(Ccc(234))
    "is" -> Ok(Ccc(240))
    "notreordered" -> Ok(Ccc(000))
    "overlay" -> Ok(Ccc(001))
    "hanreading" -> Ok(Ccc(006))
    "nukta" -> Ok(Ccc(007))
    "kanavoicing" -> Ok(Ccc(008))
    "virama" -> Ok(Ccc(009))
    "attachedbelowleft" -> Ok(Ccc(200))
    "attachedbelow" -> Ok(Ccc(202))
    "attachedabove" -> Ok(Ccc(214))
    "attachedaboveright" -> Ok(Ccc(216))
    "belowleft" -> Ok(Ccc(218))
    "below" -> Ok(Ccc(220))
    "belowright" -> Ok(Ccc(222))
    "left" -> Ok(Ccc(224))
    "right" -> Ok(Ccc(226))
    "aboveleft" -> Ok(Ccc(228))
    "above" -> Ok(Ccc(230))
    "aboveright" -> Ok(Ccc(232))
    "doublebelow" -> Ok(Ccc(233))
    "doubleabove" -> Ok(Ccc(234))
    "iotasubscript" -> Ok(Ccc(240))
    "ccc" <> str -> {
      case int.base_parse(str, 10) {
        // Fixed position class:
        Ok(i) if 10 <= i && i < 200 -> Ok(Ccc(i))
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn to_int(ccc: CombiningClass) -> Int {
  ccc.value
}

/// Returns the short name `String` of a [`CombiningClass`](#CombiningClass).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(not_reordered) = combining_class.from_int(0)
/// assert combining_class.to_short_name(not_reordered) == "NR"
///
/// let assert Ok(ccc10) = combining_class.from_int(10)
/// assert combining_class.to_short_name(ccc10) == "CCC10"
/// ```
///
pub fn to_short_name(ccc: CombiningClass) -> String {
  case ccc.value {
    000 -> "NR"
    001 -> "OV"
    006 -> "HANR"
    007 -> "NK"
    008 -> "KV"
    009 -> "VR"
    200 -> "ATBL"
    202 -> "ATB"
    214 -> "ATA"
    216 -> "ATAR"
    218 -> "BL"
    220 -> "B"
    222 -> "BR"
    224 -> "L"
    226 -> "R"
    228 -> "AL"
    230 -> "A"
    232 -> "AR"
    233 -> "DB"
    234 -> "DA"
    240 -> "IS"
    i -> "CCC" <> int.to_string(i)
  }
}

/// Returns the long name `String` of a [`CombiningClass`](#CombiningClass).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(not_reordered) = combining_class.from_int(0)
/// assert combining_class.to_long_name(not_reordered) == "Not_Reordered"
///
/// let assert Ok(ccc10) = combining_class.from_int(10)
/// assert combining_class.to_long_name(ccc10) == "CCC10"
/// ```
///
pub fn to_long_name(ccc: CombiningClass) -> String {
  case ccc.value {
    000 -> "Not_Reordered"
    001 -> "Overlay"
    006 -> "Han_Reading"
    007 -> "Nukta"
    008 -> "Kana_Voicing"
    009 -> "Virama"
    200 -> "Attached_Below_Left"
    202 -> "Attached_Below"
    214 -> "Attached_Above"
    216 -> "Attached_Above_Right"
    218 -> "Below_Left"
    220 -> "Below"
    222 -> "Below_Right"
    224 -> "Left"
    226 -> "Right"
    228 -> "Above_Left"
    230 -> "Above"
    232 -> "Above_Right"
    233 -> "Double_Below"
    234 -> "Double_Above"
    240 -> "Iota_Subscript"
    i -> "CCC" <> int.to_string(i)
  }
}

/// Returns `True` if the [`CombiningClass`](#CombiningClass) provided is a
/// fixed-position class (value between 10 and 199).
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(ccc10) = combining_class.from_int(10)
/// assert combining_class.is_fixed_position(ccc10)
/// ```
///
pub fn is_fixed_position(ccc: CombiningClass) {
  case ccc.value {
    i if 10 <= i && i < 200 -> True
    _ -> False
  }
}
