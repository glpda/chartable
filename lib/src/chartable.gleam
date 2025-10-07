import gleam/string
import gleam/string_tree

/// Converts to a loose `String` for catalog/enumeration property matching
///
/// Rule [UAX44-LM3](https://www.unicode.org/reports/tr44/#UAX44-LM3):
/// ignore case, whitespaces, underscores, hyphens, and initial prefix "is"
@internal
pub fn comparable_property(str: String) -> String {
  case string.lowercase(str) {
    "is" -> "is"
    "is" <> str -> str
    str -> str
  }
  |> string_tree.from_string()
  |> string_tree.replace(each: " ", with: "")
  |> string_tree.replace(each: "-", with: "")
  |> string_tree.replace(each: "_", with: "")
  |> string_tree.to_string()
}
