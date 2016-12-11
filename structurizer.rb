##
## MIT License
##
## Copyright (c) 2016 SilentByte <https://silentbyte.com/>
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##

require 'date'
require 'json'
require 'nokogiri'


class PinyinConverter

    # Structure *must* be ordered by length.
    DiacriticPositions = [
        ['iao', 'ia^o'],
        ['IAO', 'IA^O'],
        ['uai', 'ua^i'],
        ['UAI', 'UA^I'],
        ['ai', 'a^i'],
        ['ao', 'a^o'],
        ['ei', 'e^i'],
        ['ia', 'ia^'],
        ['ie', 'ie^'],
        ['io', 'io^'],
        ['iu', 'iu^'],
        ['AI', 'A^I'],
        ['AO', 'A^O'],
        ['EI', 'E^I'],
        ['IA', 'IA^'],
        ['IE', 'IE^'],
        ['IO', 'IO^'],
        ['IU', 'IU^'],
        ['ou', 'o^u'],
        ['ua', 'ua^'],
        ['ue', 'ue^'],
        ['ui', 'ui^'],
        ['uo', 'uo^'],
        ['üe', 'üe^'],
        ['OU', 'O^U'],
        ['UA', 'UA^'],
        ['UE', 'UE^'],
        ['UI', 'UI^'],
        ['UO', 'UO^'],
        ['ÜE', 'ÜE^'],
        ['a', 'a^'],
        ['e', 'e^'],
        ['i', 'i^'],
        ['o', 'o^'],
        ['u', 'u^'],
        ['ü', 'ü^'],
        ['m', 'm^'],
        ['r', 'r^'],
        ['A', 'A^'],
        ['E', 'E^'],
        ['I', 'I^'],
        ['O', 'O^'],
        ['U', 'U^'],
        ['Ü', 'Ü^'],
        ['M', 'M^'],
        ['R', 'R^']
    ]

    DiacriticCandidates = [
        'a^', 'e^', 'i^' ,'o^' ,'u^', 'ü^', 'm^', 'r^', 'A^', 'E^', 'I^', 'O^', 'U^', 'Ü^', 'M^', 'R^'
    ]

    DiacriticCharacters = [
        ['ā', 'ē', 'ī', 'ō', 'ū', 'ǖ', 'm̄', 'r', 'Ā', 'Ē', 'Ī', 'Ō', 'Ū', 'Ǖ', 'M̄', 'R'],
        ['á', 'é', 'í', 'ó', 'ú', 'ǘ', 'ḿ', 'r', 'Á', 'É', 'Í', 'Ó', 'Ú', 'Ǘ', 'Ḿ', 'R'],
        ['ǎ', 'ě', 'ǐ', 'ǒ', 'ǔ', 'ǚ', 'm̌', 'r', 'Ǎ', 'Ě', 'Ǐ', 'Ǒ', 'Ǔ', 'Ǚ', 'M̌', 'R'],
        ['à', 'è', 'ì', 'ò', 'ù', 'ǜ', 'm̀', 'r', 'À', 'È', 'Ì', 'Ò', 'Ù', 'Ǜ', 'M̀', 'R'],
        ['a', 'e', 'i', 'o', 'u', 'ü', 'm', 'r', 'A', 'E', 'I', 'O', 'U', 'Ü', 'M', 'R']
    ]

    def parse_match(word, tone)
        DiacriticPositions.each do |p|
            break if word.gsub!(p[0], p[1])
        end

        DiacriticCandidates.each_with_index do |c, i|
            break if word.gsub!(c, DiacriticCharacters[tone.to_i - 1][i])
        end

        return word
    end

    def numeric_to_diacritic(pinyin)
        # Only consider words ending with a tone indicator.
        return pinyin.gsub(/([a-zA-ZüÜ]+)(\d)/) { self.parse_match($1, $2) }
    end
end

class CedictParser
    def initialize
        @pinyinConverter = PinyinConverter.new
    end

    def get_fields(line)
        regex = /^(?<traditional>.+?) (?<simplified>.+?) \[(?<pinyin>.+?)\] (?<definitions>\/.+\/)/
        return regex.match(line)
    end

    def get_characters(characters)
        return characters.scan(/\p{Han}/)
    end

    def get_numeric_pinyin(pinyin)
        return pinyin.sub('u:', 'ü').sub('U:', 'Ü')
    end

    def get_diacritic_pinyin(pinyin)
        return @pinyinConverter.numeric_to_diacritic(pinyin)
    end

    def get_definitions(definitions)
        return definitions.split('/').reject { |m| m.empty? }
    end

    def get_diacritic_definitions(definitions)
        return self.get_definitions(definitions).map! { |d| d.gsub(/(\[.+?\])/) { self.get_diacritic_pinyin($1) } }
    end

    def parse_line(line)
        if not line[0] or line[0] == '#'
            return nil
        end

        fields = self.get_fields(line)
        if not fields
            raise 'Dictionary entry is invalid.'
            return nil
        end

        return {
            :traditional => fields[:traditional],
            :simplified => fields[:simplified],
            :referencedTraditional => self.get_characters(fields[:traditional]),
            :referencedSimplified => self.get_characters(fields[:simplified]),
            :pinyinNumeric => self.get_numeric_pinyin(fields[:pinyin]),
            :pinyinDiacritic => self.get_diacritic_pinyin(fields[:pinyin]),
            :definitions => self.get_definitions(fields[:definitions]),
            :definitionsDiacritic => self.get_diacritic_definitions(fields[:definitions])
        }
    end
end

class GenericStructurizer
    def structurize(definition_file, output_file)
        File.open(output_file, 'w') do |output|
            line_counter = 0
            parser = CedictParser.new

            output.write(self.document_preamble)
            IO.foreach(definition_file) do |line|
                line_counter += 1

                begin
                    object = parser.parse_line(line)
                rescue => e
                    STDERR.puts "Invalid dictionary entry on line #{line_counter}.",
                                " -> #{e}"
                end

                if not object
                    next
                end

                output.write(self.object_prefix(object))
                output.write(self.object_data(object))
                output.write(self.object_postfix(object))
            end
            output.write(self.document_postamble)
        end
    end
end

class JsonStructurizer < GenericStructurizer
    def initialize
        @is_first = true
    end

    def document_preamble
        return "[\n"
    end

    def document_postamble
        return "\n]"
    end

    def object_prefix(object)
        if @is_first
            @is_first = false
            return '    '
        else
            return ",\n    "
        end
    end

    def object_postfix(object)
        return ''
    end

    def object_data(object)
        return object.to_json
    end
end

class XmlStructurizer < GenericStructurizer
    def document_preamble
        date = DateTime.now.iso8601
        return '<?xml version="1.0" encoding="utf-8" ?>' + "\n" +
            "<cc-cedict created=\"#{date}\">\n"
    end

    def document_postamble
        return '</cc-cedict>'
    end

    def object_prefix(object)
        return ''
    end

    def object_postfix(object)
        return "\n"
    end

    def object_data(object)
        builder = Nokogiri::XML::Builder.new do |xml|
            xml.entry {
                xml.traditional object[:traditional]
                xml.simplified object[:simplified]
                xml.send('referenced-traditional') {
                    object[:referencedTraditional].each { |c| xml.character c }
                }
                xml.send('referenced-simplified') {
                    object[:referencedSimplified].each { |c| xml.character c }
                }
                xml.send('pinyin-numeric', object[:pinyinNumeric])
                xml.send('pinyin-diacritic', object[:pinyinDiacritic])
                xml.definitions {
                    object[:definitions].each { |c| xml.definition c }
                }
                xml.send('definitions-diacritic') {
                    object[:definitionsDiacritic].each { |c| xml.definition c }
                }
            }
        end

        return builder.doc.root.to_xml
    end
end

class CsvStructurizer < GenericStructurizer
    def structurize(definition_file, output_file)
        STDERR.puts 'CSV structurizer is not implemented yet.'
    end
end

def main(format, definition_file, output_file)
    structurizer = case format
                   when 'json' then JsonStructurizer.new
                   when 'xml'  then XmlStructurizer.new
                   when 'csv'  then CsvStructurizer.new
                   else raise "Format '#{format}' is unknown."
                   end

    structurizer.structurize(definition_file, output_file)
end

main(ARGV[0], ARGV[1], ARGV[2])

