
default: codegen test-lib

[working-directory('lib')]
codegen: fetch
	gleam dev

[working-directory('app')]
serve-app:
	gleam run -m lustre/dev start

[working-directory('app')]
build-app:
	gleam run -m lustre/dev build --minify

# ==============================================================================
# BEGIN Test Recipes

[group('test')]
test: test-lib test-app

[group('test'), working-directory('lib')]
test-lib:
	-gleam test
	-gleam run -m birdie review

[group('test'), working-directory('app')]
test-app:
	-gleam test

# END

# ==============================================================================
# BEGIN Fetch Recipes

[group('fetch')]
fetch: fetch-unidata fetch-html fetch-latex fetch-typst

[group('fetch'), private]
download url file:
	mkdir -p `dirname tmp/{{file}}`
	wget -q --output-document tmp/{{file}} {{url}}/{{file}}

data-path := "lib/data"
[group('fetch'), private]
add-data source target:
	mkdir -p `dirname {{data-path}}/{{target}}`
	mv tmp/{{source}} {{data-path}}/{{target}}

[group('fetch'), private]
dl-data url file target: (download url file) (add-data file target)

unidata := "https://www.unicode.org/Public/UCD/latest/ucd"
[group('fetch')]
fetch-unidata: \
(dl-data unidata "PropertyValueAliases.txt" "unicode/property-value-aliases.txt") \
(dl-data unidata "UnicodeData.txt" "unicode/data.txt") \
(dl-data unidata "NameAliases.txt" "unicode/name-aliases.txt") \
(dl-data unidata "extracted/DerivedName.txt" "unicode/names.txt") \
(dl-data unidata "extracted/DerivedGeneralCategory.txt" "unicode/categories.txt") \
(dl-data unidata "Blocks.txt" "unicode/blocks.txt") \
(dl-data unidata "Scripts.txt" "unicode/scripts.txt") \
(dl-data unidata "ScriptExtensions.txt" "unicode/script-extensions.txt")

whatwg := "https://html.spec.whatwg.org/"
html-entities := "entities.json"
html-entities-clean := "entities-clean.json"
[group('fetch')]
fetch-html: \
(download whatwg html-entities) \
(clean-entities) \
(add-data html-entities-clean "html/entities.json")

entities-filter := \
	'with_entries(select(.key | startswith("&") and endswith(";"))' + \
	' | .key |= ltrimstr("&")' + \
	' | .key |= rtrimstr(";") )' + \
	' | map_values(.codepoints | implode)'
[group('fetch'), private]
clean-entities:
	jq '{{entities-filter}}' \
	tmp/{{html-entities}} > tmp/{{html-entities-clean}}

latex3 := "https://raw.githubusercontent.com/latex3/unicode-math/refs/heads/master/"
[group('fetch')]
fetch-latex: \
(dl-data latex3 "unicode-math-table.tex" "latex/unicode-math.tex")

typst-codex := "https://raw.githubusercontent.com/typst/codex/refs/heads/main/src/modules"
[group('fetch')]
fetch-typst: \
(dl-data typst-codex "sym.txt" "typst/sym.txt") \
(dl-data typst-codex "emoji.txt" "typst/emoji.txt")

# END
