# CharTable

🎒 Character table (cartable = schoolbag in French)

An application to explore the Unicode database.

🚧 **UNDER CONSTRUCTION** 🚧

Features: ...

Inspirations (a prior art list):
- [John Factotum's Runemaster](https://github.com/johnfactotum/runemaster)
- [Gnome Characters](https://apps.gnome.org/Characters/)
- [KDE KCharSelect](https://apps.kde.org/kcharselect/)
- [EmNudge's Unicode Lookup](https://unicode.emnudge.dev/)
- [r21a UniView](https://r12a.github.io/uniview/)
- [KreativeKorp Unicode Character Charts](https://www.kreativekorp.com/charset/unicode/)
- [decode unicode](https://decodeunicode.org/en/u+00041)
- [Compart Unicode](https://www.compart.com/en/unicode/)
- [Codepoints.net](https://codepoints.net/)
- [Typst ASCII Table](https://typst.app/tools/ascii-table/)


## Development

Requirements:
[gleam](https://gleam.run/) (+ javascript runtime),
[jq](https://jqlang.org/),
[just](https://just.systems/),
[wget](https://www.gnu.org/software/wget/).

```sh
just codegen   # Dowload source data and generate library code
just test-lib  # Run the library tests
```
