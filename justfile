
default: codegen test-lib

[working-directory('lib')]
codegen: fetch
	gleam dev

[working-directory('app')]
serve-app:
	gleam run -m serve

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
fetch: fetch-unidata fetch-html fetch-typst

[group('fetch'), private]
download url file:
	mkdir -p `dirname tmp/{{file}}`
	wget -q --output-document tmp/{{file}} {{url}}/{{file}}

data-path := "lib/data"
[group('fetch'), private]
add-data source target:
	mkdir -p `dirname {{data-path}}/{{target}}`
	mv tmp/{{source}} {{data-path}}/{{target}}

unidata := "https://www.unicode.org/Public/UCD/latest/ucd"
property-value-aliases := "PropertyValueAliases.txt"
derived-name := "extracted/DerivedName.txt"
categories := "extracted/DerivedGeneralCategory.txt"
blocks := "Blocks.txt"
scripts := "Scripts.txt"
script-extensions := "ScriptExtensions.txt"
[group('fetch')]
fetch-unidata: \
(download unidata property-value-aliases) \
(add-data property-value-aliases "unicode/property-value-aliases.txt") \
(download unidata derived-name) \
(add-data derived-name "unicode/names.txt") \
(download unidata categories) \
(add-data categories "unicode/categories.txt") \
(download unidata blocks) \
(add-data blocks "unicode/blocks.txt") \
(download unidata scripts) \
(add-data scripts "unicode/scripts.txt") \
(download unidata script-extensions) \
(add-data script-extensions "unicode/script-extensions.txt")

entities-filter := \
	'with_entries(select(.key | startswith("&") and endswith(";"))' + \
	' | .key |= ltrimstr("&")' + \
	' | .key |= rtrimstr(";") )' + \
	' | map_values(.codepoints | implode)'
[group('fetch'), private]
clean-entities:
	jq '{{entities-filter}}' \
	tmp/{{html-entities}} > tmp/{{html-entities-clean}}

whatwg := "https://html.spec.whatwg.org/"
html-entities := "entities.json"
html-entities-clean := "entities-clean.json"
[group('fetch')]
fetch-html: \
(download whatwg html-entities) \
(clean-entities) \
(add-data html-entities-clean "html/entities.json")

typst-codex := "https://raw.githubusercontent.com/typst/codex/refs/heads/main/src/modules"
typst-sym := "sym.txt"
typst-emoji := "emoji.txt"
[group('fetch')]
fetch-typst: \
(download typst-codex typst-sym) \
(download typst-codex typst-emoji) \
(add-data typst-sym "typst/sym.txt") \
(add-data typst-emoji "typst/emoji.txt")

# END
