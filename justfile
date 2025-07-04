
# dependencies: echo, gleam, jq, sed, unzip, wget

lib-path := "lib/src/chartable"

unidata := "https://www.unicode.org/Public/UNIDATA"
ucd := "UCD.zip"
unihan := "Unihan.zip"

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

# [group('fetch')]
# copy source target:
# 	cp tmp/{{source}} {{lib-path}}/data/{{target}}
# move instead of copy?

[group('fetch')]
fetch-all: fetch-unidata

[group('fetch')]
fetch-unidata: \
(download unidata ucd) \
(download unidata unihan) \
(extract ucd "unicode") \
(extract unihan "unicode")

# clear:
# 	rm -r tmp/*

