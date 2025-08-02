import chartable/internal/unicode_codegen
import simplifile

pub fn main() {
  let assert Ok(names) = simplifile.read("data/unicode/names.txt")
  let assert Ok(codegen_src) = simplifile.read("data/unicode/name_map.mjs")
  let assert Ok(Nil) =
    simplifile.write(
      to: "src/chartable/unicode/name_map.mjs",
      contents: unicode_codegen.make_name_map(names:, codegen_src:),
    )
}
