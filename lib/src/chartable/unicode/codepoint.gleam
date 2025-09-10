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
// END
