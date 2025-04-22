require 'yaml'
require './src/Parser/ast_node'


class Parser
    def initialize(tokens)
        @tokens = tokens
        @current_tokens = nil
        @module = AST_Module.new
        @keywords = YAML.safe_load_file('keywords.yml', aliases: true)
    end

    def parse
        while @tokens.any?
            @current_tokens = @tokens.shift
            next if @current_tokens.empty?
            @module.body << parse_statement
        end
        @module
    end

    private

    def parse_statement
        statement_tokens = @current_tokens.take_while { |token| token != ":" }
        @keywords["statement"].each do |k, v|
            if statement_tokens.any? { |token| token.match?(v) }
                return send("parse_#{k}")
            end
        end
        raise "Invalid statement: #{statement_tokens}"
    end

    def parse_assignment
        name = 
            case @current_tokens[1]
            when "[" then parse_subscript(:store)
            else parse_name(:store)
            end
        skip("=")
        value = 
            case @current_tokens.first
            when "[" then parse_array
            when "{" then parse_dict
            else parse_expression
            end
        AST_Assign.new(name, value)
    end

    def parse_expression = parse_binop(:term, %w(+ -))
    def parse_term = parse_binop(:factor, %w(* /))
    def parse_binop(method, ops)
        res = send("parse_#{method}")
        while ops.include?(@current_tokens.first)
            op = @current_tokens.shift.to_sym
            res = AST_BinOp.new(res, op, send("parse_#{method}"))
        end
        res
    end

    def parse_factor
        @keywords["factor"].each do |k, v|
            if @current_tokens.first.match?(v)
                return send("parse_#{k}")
            end
        end
    end

    def parse_paren
        skip("(")
        parse_expression
    end

    def parse_identifier
        @keywords["identifier"].each do |k, v|
            if @current_tokens[1]&.match?(v)
                return send("parse_#{k}")
            end
        end
        return parse_name(:load)
    end

    def parse_array
        skip("[")
        array = []
        until @current_tokens.first == "]"
            array << parse_expression
            @current_tokens.shift if @current_tokens.first == ","
        end
        skip("]")
        AST_Array.new(array)
    end

    def parse_dict
        skip("{")
        dict = {}
        until @current_tokens.first == "}"
            key = parse_expression
            skip(":")
            value = parse_expression
            dict[key] = value
            @current_tokens.shift if @current_tokens.first == ","
        end
        skip("}")
        AST_Dict.new(dict)
    end

    def parse_subscript(ctx=:load)
        name = parse_name(:load)
        skip("[")
        index = parse_expression
        skip("]")
        AST_Subscript.new(name, index, ctx)
    end

    def parse_name(ctx=:load) = AST_Name.new(@current_tokens.shift, ctx)

    def parse_number = @current_tokens.shift.to_i

    def parse_string = @current_tokens.shift[1..-2]

    def parse_if
        skip("if")
        condition = parse_comparison
        skip(":")
        body = parse_block
        AST_If.new(condition, body)
    end

    def parse_loop
        skip("loop")
        if @current_tokens.include?("~")
            if @current_tokens.include?("<-")
                name = parse_name(:store)
                skip("<-")
            end
            condition = parse_range
        else
            condition = parse_comparison
        end
        skip(":")
        body = parse_block
        AST_Loop.new(condition, body, name || nil)
    end

    def parse_comparison
        left = parse_expression
        op = @current_tokens.shift.to_sym
        right = parse_expression
        AST_Compare.new(left, op, right)
    end

    def parse_range
        start = parse_expression
        skip("~")
        stop = parse_expression
        AST_Range.new(start, stop)
    end

    def parse_block
        block_tokens = @current_tokens.shift
        body = []
        while block_tokens.any?
            @current_tokens = block_tokens.shift
            next if @current_tokens.empty?
            body << parse_statement
        end
        AST_Block.new(body)
    end

    def parse_function
        skip("ƒ")
        name = parse_name(:store)
        skip("(")
        args = []
        until @current_tokens.first == ")"
            args << @current_tokens.shift
            @current_tokens.shift if @current_tokens.first == ","
        end
        skip(")")
        skip(":")
        body = parse_block
        AST_Function.new(name, args, body)
    end

    def parse_return
        skip(@keywords["token"]["return"])
        AST_Return.new(parse_expression)
    end

    def parse_call
        name = parse_name(:load)
        skip("(")
        args = []
        until @current_tokens.first == ")"
            args << parse_expression
            @current_tokens.shift if @current_tokens.first == ","
        end
        skip(")")
        AST_Call.new(name, args)
    end

    def skip(value)
        if @current_tokens.first == value
            @current_tokens.shift
        else
            raise "Expected #{value} but got #{@current_tokens.first}"
        end
    end
end