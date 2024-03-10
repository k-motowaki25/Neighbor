require 'strscan'


class Tokenizer
    def initialize(code)
        @code = code
        @tokens = []
        @keywords = YAML.safe_load_file('keywords.yml', aliases: true)
    end

    def tokenize
        lines = @code.split("\n")

        @tokens = process_line(lines)
        @tokens
    end

    private

    def process_line(lines, current_indent=0)
        tokens = []
        while lines.any?
            indent = lines.first[/\A */].size
            if indent == current_indent
                tokens << tokenize_line(lines.shift)
            elsif indent > current_indent
                tokens.last << process_line(lines, indent)
            else
                break
            end
        end
        tokens
    end

    def tokenize_line(line)
        scanner = StringScanner.new(line)
        pattern = @keywords["token"].values.join('|')
        tokens = []
        until scanner.eos?
            scanner.skip(/\s+|,/)
            token = scanner.scan(/#{pattern}/)
            tokens << token if token
        end
        tokens
    end
end
