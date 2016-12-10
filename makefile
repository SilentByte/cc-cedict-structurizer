
.PHONY: all update everything json xml csv

all:
	@echo 'CC-CEDICT Structurizer Usage'
	@echo '  make update       Update the CC-CEDICT dictionary definitions.'
	@echo '  make everything   Generate JSON, XML, and CSV output files.'
	@echo '  make json         Generate JSON output files.'
	@echo '  make xml          Generate XML output files.'
	@echo '  make csv          Generate CSV output files.'

update: ./cc-cedict/cc-cedict.u8

everything: update json xml csv

json: ./cc-cedict/cc-cedict.json

xml: ./cc-cedict/cc-cedict.xml

csv: ./cc-cedict/cc-cedict.csv

./cc-cedict/cc-cedict.u8:
	mkdir -p ./cc-cedict/
	curl 'https://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz' | gzip -d >./cc-cedict/cc-cedict.u8

./cc-cedict/cc-cedict.json:
	@echo 'JSON output is not yet implemented.'

./cc-cedict/cc-cedict.xml:
	@echo 'XML output is not yet implemented.'

./cc-cedict/cc-cedict.csv:
	@echo 'CSV output is not yet implemented.'
