
lib-path := "lib/src/chartable"
data-path := "lib/data"

unidata := "https://www.unicode.org/Public/UCD/latest/ucd"
derived-name := "extracted/DerivedName.txt"

whatwg := "https://html.spec.whatwg.org/"
html-entities := "entities.json"
html-entities-clean := "entities-clean.json"

typst-codex := "https://raw.githubusercontent.com/typst/codex/refs/heads/main/src/modules"
typst-sym := "sym.txt"
typst-emoji := "emoji.txt"


default: codegen test-lib

[group('test'), working-directory('lib')]
test-lib:
	-gleam test
	-gleam run -m birdie review

[group('fetch'), private]
download url file:
	mkdir -p `dirname tmp/{{file}}`
	wget -q --output-document tmp/{{file}} {{url}}/{{file}}

[group('fetch'), private]
add-data source target:
	mkdir -p `dirname {{data-path}}/{{target}}`
	mv tmp/{{source}} {{data-path}}/{{target}}

[working-directory('lib')]
codegen: fetch-all
	gleam dev

[group('fetch')]
fetch-all: fetch-unidata fetch-html fetch-typst

[group('fetch')]
fetch-unidata: \
(download unidata derived-name) \
(add-data derived-name "unicode/names.txt")

entities-filter := \
	'with_entries(select(.key | startswith("&") and endswith(";"))' + \
	' | .key |= ltrimstr("&")' + \
	' | .key |= rtrimstr(";") )' + \
	' | map_values(.codepoints | implode)'

[group('fetch'), private]
clean-entities:
	jq '{{entities-filter}}' \
	tmp/{{html-entities}} > tmp/{{html-entities-clean}}

[group('fetch')]
fetch-html: \
(download whatwg html-entities) \
(clean-entities) \
(add-data html-entities-clean "html/entities.json")

[group('fetch')]
fetch-typst: \
(download typst-codex typst-sym) \
(download typst-codex typst-emoji) \
(add-data typst-sym "typst/sym.txt") \
(add-data typst-emoji "typst/emoji.txt")


# clear:
# 	rm -r tmp/*

