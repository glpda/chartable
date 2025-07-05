
# dependencies: echo, gleam, jq, sed, unzip, wget

lib-path := "lib/src/chartable"

unidata := "https://www.unicode.org/Public/UNIDATA"
ucd := "UCD.zip"
unihan := "Unihan.zip"

whatwg := "https://html.spec.whatwg.org/"
html-entities := "entities.json"
html-entities-clean := "entities-clean.json"

typst-codex := "https://raw.githubusercontent.com/typst/codex/refs/heads/main/src/modules/"
typst-sym := "sym.txt"
typst-emoji := "emoji.txt"


default: fetch-all

[group('test'), working-directory('lib')]
test-lib:
	-gleam test
	-gleam run -m birdie review

[group('fetch')]
download url file:
	wget -q --output-document tmp/{{file}} {{url}}/{{file}}

[group('fetch')]
extract file target:
	unzip -d tmp/{{target}} tmp/{{file}}
# 7z x -o tmp/{{target}} tmp/{{file}}

[group('fetch')]
make-const source target const="txt":
	echo 'pub const {{const}} = "' > {{lib-path}}/{{target}}.gleam
	sed 's/\\/\\\\/g; s/"/\\"/g'  < tmp/{{source}} \
	>> {{lib-path}}/{{target}}.gleam
	echo '"' >> {{lib-path}}/{{target}}.gleam

# [group('fetch')]
# copy source target:
# 	cp tmp/{{source}} {{lib-path}}/data/{{target}}
# move instead of copy?

[group('fetch')]
fetch-all: fetch-unidata fetch-html fetch-typst

[group('fetch')]
fetch-unidata: \
(download unidata ucd) \
(download unidata unihan) \
(extract ucd "unicode") \
(extract unihan "unicode")

entities-filter := \
	'with_entries(select(.key | startswith("&") and endswith(";"))' + \
	' | .key |= ltrimstr("&")' + \
	' | .key |= rtrimstr(";") )' + \
	' | map_values(.codepoints | implode)'

[group('fetch')]
clean-entities:
	jq '{{entities-filter}}' \
	tmp/{{html-entities}} > tmp/{{html-entities-clean}}

[group('fetch')]
fetch-html: \
(download whatwg html-entities) \
(clean-entities) \
(make-const html-entities-clean "html/entities" "json")

[group('fetch')]
fetch-typst: \
(download typst-codex typst-sym) \
(download typst-codex typst-emoji) \
(make-const typst-sym "typst/sym") \
(make-const typst-emoji "typst/emoji")


# clear:
# 	rm -r tmp/*

