
CC-CEDICT Structurizer
======================

This program is designed to extract and process entries from the CC-CEDICT Chinese/English Dictionary and output structured data (i.e. JSON, XML, CSV) for further usage.

The files in this repository provide the following structured information *for each word* from the dictionary:

* Traditional Chinese characters
* Simplified Chinese characters
* Referenced traditional Chinese characters
* Referenced simplified Chinese characters
* Numeric Pinyin (e.g. Zhong1guo2)
* Diacritic Pinyin (e.g. Zhōngguó)
* English definitions

The relevant data can be found here:
https://www.mdbg.net/chindict/chindict.php?page=cedict


## General Usage
All output files (JSON, XML, and CSV) are directly provided with this repository and made available for use. A manual update can be triggered using the provided makefile. Ruby 2.3.0 and the Nokogiri gem (XML) are required.

```make
CC-CEDICT Structurizer Usage
  make update       Update CC-CEDICT dictionary definitions.
  make everything   Update CC-CEDICT dictionary and generate all output files.
  make generate     Generate all output files.
  make json         Generate JSON output files.
  make xml          Generate XML output files.
  make csv          Generate CSV output files.
```

## Licensing

MIT License

Copyright (c) 2016 SilentByte <https://silentbyte.com/>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

