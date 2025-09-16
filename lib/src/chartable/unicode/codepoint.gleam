import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/string

// =============================================================================
// BEGIN Custom Code Point

/// Custom type representing any code point in the Unicode codespace,
/// i.e. any integers from `0` to `0x10FFFF` including surrogates
/// (unlike standard Gleam `UtfCodepoint` wich excludes them).
///
/// Surrogates are not valid Unicode scalar values for interchange,
/// `UtfCodepoint` is preferable in most cases (for string processing),
/// but including surrogates is useful when looking up data about some code
/// point (e.g. its general category) which is all this library is about.
///
/// ## Examples
///
/// ```gleam
/// let assert Ok(cp) = codepoint.from_int(0xD800)
/// assert unicode.category_from_codepoint(cp) == category.Surrogate
/// ```
///
pub opaque type Codepoint {
  Codepoint(value: Int)
}

/// Smallest possible code point: `0`.
pub const minimum = Codepoint(0)

/// Greatest possible code point: `0x10FFFF`.
pub const maximum = Codepoint(0x10FFFF)

/// Converts a standard `UtfCodepoint` to a chartable [`Codepoint`](#Codepoint).
pub fn from_utf(utf: UtfCodepoint) -> Codepoint {
  Codepoint(string.utf_codepoint_to_int(utf))
}

/// Converts an integer to a chartable [`Codepoint`](#Codepoint).
///
/// Returns an `Error` if the integer is not between `0` and `0x10FFFF`.
pub fn from_int(value: Int) -> Result(Codepoint, Nil) {
  case value {
    i if i > 0x10FFFF -> Error(Nil)
    i if i < 0 -> Error(Nil)
    i -> Ok(Codepoint(i))
  }
}

/// Converts a chartable [`Codepoint`](#Codepoint) to a standard `UtfCodepoint`.
///
/// Returns an `Error` if the code point is a surrogate.
pub fn to_utf(cp: Codepoint) -> Result(UtfCodepoint, Nil) {
  // NOTE: could skip useless comparisons by directly calling the external
  // implementations of "unsafe_int_to_utf_codepoint", but this would break the
  // contract of the sandard library.
  string.utf_codepoint(cp.value)
}

/// Converts a chartable [`Codepoint`](#Codepoint) to its ordinal value.
pub fn to_int(cp: Codepoint) -> Int {
  cp.value
}

/// Compares two code points, returning an order.
pub fn compare(lhs: Codepoint, rhs: Codepoint) -> Order {
  int.compare(lhs.value, rhs.value)
}

/// Compares two code points, returning the larger of the two.
pub fn max(lhs: Codepoint, rhs: Codepoint) -> Codepoint {
  case lhs.value > rhs.value {
    True -> lhs
    False -> rhs
  }
}

/// Compares two code points, returning the smaller of the two.
pub fn min(lhs: Codepoint, rhs: Codepoint) -> Codepoint {
  case lhs.value < rhs.value {
    True -> lhs
    False -> rhs
  }
}

// END

// =============================================================================
// BEGIN Code Point Range

/// A range of [`Codepoint`](#Codepoint), essentially a pair of code points
/// which is always ordered.
pub opaque type Range {
  Range(start: Codepoint, end: Codepoint)
}

/// Get a [`Range`](#Range) from a pair of [`Codepoint`](#Codepoint)s.
pub fn range_from_codepoints(left: Codepoint, right: Codepoint) -> Range {
  case left.value <= right.value {
    True -> Range(start: left, end: right)
    False -> Range(start: right, end: left)
  }
}

/// Get a [`Range`](#Range) from a pair of integers.
///
/// Returns an `Error` if one of the integers is not between `0` and `0x10FFFF`.
pub fn range_from_ints(left: Int, right: Int) -> Result(Range, Nil) {
  case from_int(left), from_int(right) {
    Ok(start), Ok(end) if left <= right -> Ok(Range(start:, end:))
    Ok(end), Ok(start) -> Ok(Range(start:, end:))
    _, _ -> Error(Nil)
  }
}

/// Get the [`Codepoint`](#Codepoint) boundaries of a [`Range`](#Range).
///
/// The output will always be ordered (first ≤ second).
pub fn range_to_codepoints(range: Range) -> #(Codepoint, Codepoint) {
  #(range.start, range.end)
}

/// Get the ordinal value of the boundaries of a [`Range`](#Range).
///
/// The output will always be ordered (first ≤ second).
pub fn range_to_ints(range: Range) -> #(Int, Int) {
  #(range.start.value, range.end.value)
}

/// Get the list of code points in a given [`Range`](#Range).
pub fn range_to_list(range: Range) -> List(Codepoint) {
  // NOTE: This function does not perform any bounds checking because every
  // code point between two valid code points are guaranteed to be also valid
  // (since surrogates are considered valid, so there is no "holes").
  list.range(range.start.value, range.end.value) |> list.map(Codepoint)
}

pub fn range_length(range: Range) -> Int {
  range.end.value - range.start.value + 1
}

/// Compares two code point ranges; they are considered equal if there is any
/// overlapping between the two.
pub fn range_compare(lhs: Range, rhs: Range) -> Order {
  // compare(lhs.start, rhs.start) |> order.break_tie(compare(lhs.end, rhs.end))
  case compare(lhs.end, rhs.start), compare(rhs.end, lhs.start) {
    // <--lhs-->  <--rhs-->
    order.Lt, _ -> order.Lt
    // <--rhs-->  <--lhs-->
    _, order.Lt -> order.Gt
    _, _ -> order.Eq
  }
}

/// Get the range of code points that are in both given codepoint ranges.
///
/// Returns an `Error` if there is no overlapping between the two ranges.
pub fn range_intersection(of r1: Range, and r2: Range) -> Result(Range, Nil) {
  let #(r1_start, r1_end) = range_to_ints(r1)
  let #(r2_start, r2_end) = range_to_ints(r2)
  case r1_start <= r2_start {
    True if r1_end < r2_start -> Error(Nil)
    True if r2_end <= r1_end -> Ok(r2)
    True -> Ok(Range(Codepoint(r2_start), Codepoint(r1_end)))
    // r2_start < r1_start:
    False if r2_end < r1_start -> Error(Nil)
    False if r1_end <= r2_end -> Ok(r1)
    False -> Ok(Range(Codepoint(r1_start), Codepoint(r2_end)))
  }
}

/// Get the range of code points that are in either given codepoint ranges.
///
/// Returns an `Error` if there is no overlapping between the two ranges.
pub fn range_union(of r1: Range, and r2: Range) -> Result(Range, Nil) {
  let #(r1_start, r1_end) = range_to_ints(r1)
  let #(r2_start, r2_end) = range_to_ints(r2)
  case r1_start <= r2_start {
    True if r1_end + 1 == r2_start ->
      Ok(Range(Codepoint(r1_start), Codepoint(r2_end)))
    True if r1_end < r2_start -> Error(Nil)
    True if r2_end <= r1_end -> Ok(r1)
    True -> Ok(Range(Codepoint(r1_start), Codepoint(r2_end)))
    // r2_start < r1_start:
    False if r2_end + 1 == r1_start ->
      Ok(Range(Codepoint(r2_start), Codepoint(r1_end)))
    False if r2_end < r1_start -> Error(Nil)
    False if r1_end <= r2_end -> Ok(r2)
    False -> Ok(Range(Codepoint(r2_start), Codepoint(r1_end)))
  }
}
