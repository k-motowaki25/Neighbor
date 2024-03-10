require "./src/Parser/tokenizer"
require "./src/Parser/parser"
require "./src/visitor"


FILENAME = ARGV[0]

tokenizer = Tokenizer.new(File.read(FILENAME, encoding: "UTF-8"))
tokens = tokenizer.tokenize
# p tokens

parser = Parser.new(tokens)
ast = parser.parse
# p ast
# ast.body.each { |node| p node}

visitor = Visitor.new
ast.accept(visitor)