
.PHONY: all update everything json xml csv

all:
	@echo 'CC-CEDICT Structurizer Usage'
	@echo '  make update       Update CC-CEDICT dictionary definitions.'
	@echo '  make everything   Update CC-CEDICT dictionary and generate all output files.'
	@echo '  make generate     Generate all output files.'
	@echo '  make json         Generate JSON output files.'
	@echo '  make xml          Generate XML output files.'
	@echo '  make csv          Generate CSV output files.'

clean:
	rm -f ./cc-cedict/cc-cedict.json
	rm -f ./cc-cedict/cc-cedict.xml
	rm -f ./cc-cedict/cc-cedict.csv

update:
	mkdir -p ./cc-cedict/
	curl 'https://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz' | gzip -d >./cc-cedict/cc-cedict.u8

everything: update generate

generate: json xml csv

json: ./cc-cedict/cc-cedict.json

xml: ./cc-cedict/cc-cedict.xml

csv: ./cc-cedict/cc-cedict.csv

./cc-cedict/cc-cedict.u8:
	mkdir -p ./cc-cedict/
	curl 'https://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz' | gzip -d >./cc-cedict/cc-cedict.u8

./cc-cedict/cc-cedict.json: ./cc-cedict/cc-cedict.u8
	ruby structurizer.rb json ./cc-cedict/cc-cedict.u8 ./cc-cedict/cc-cedict.json

./cc-cedict/cc-cedict.xml: ./cc-cedict/cc-cedict.u8
	ruby structurizer.rb xml ./cc-cedict/cc-cedict.u8 ./cc-cedict/cc-cedict.xml

./cc-cedict/cc-cedict.csv: ./cc-cedict/cc-cedict.u8
	ruby structurizer.rb csv ./cc-cedict/cc-cedict.u8 ./cc-cedict/cc-cedict.csv

