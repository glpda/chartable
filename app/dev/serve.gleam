import esgleam

pub fn main() {
  esgleam.new(outdir: "./dist")
  |> esgleam.entry("chartable_app.gleam")
  |> esgleam.watch(True)
  |> esgleam.serve(dir: "./")
  |> esgleam.bundle
}
