require './src/Lib/builtin'


class Visitor
    def visit(node, context = {})
        method_name = "visit_#{node.class.name.downcase}"
        send(method_name, node, context)
    end
  
    def visit_ast_module(node, context)
        node.body.each { |child| visit(child, context) }
    end

    def visit_ast_name(node, context)
        case node.ctx
        when :load
            raise "Undefined: #{node.id}" unless context.key?(node.id)
            context[node.id]
        when :store
            node.id
        end
    end

    def visit_ast_assign(node, context)
        if node.target.is_a?(AST_Subscript)
            value = visit(node.value, context)
            target, index = visit(node.target, context)
            target[index] = value
        else
            name = visit(node.target, context)
            context[name] = visit(node.value, context)
        end
    end
  
    def visit_ast_binop(node, context)
        left = visit(node.left, context)
        right = visit(node.right, context)
        left.send(node.op, right)
    end

    def visit_ast_function(node, context)
        name = visit(node.name, context)
        context[name] = node
    end

    def visit_ast_call(node, context)
        name = node.func.id
        if Builtin.respond_to?("builtin_#{name}")
            args = node.args.map { |arg| visit(arg, context) }
            return Builtin.send("builtin_#{name}", *args)
        else
            func = visit(node.func, context)
            func_context = context.clone
            func.args.zip(node.args).each do |arg_name, arg_value|
                func_context[arg_name] = visit(arg_value, context)
            end
            visit(func.body, func_context)
        end
    end

    def visit_ast_if(node, context)
        if visit(node.condition, context)
            visit(node.body, context)
        end
    end

    def visit_ast_loop(node, context)
        condition = node.condition
        if condition.is_a?(AST_Range)
            range = visit(condition, context)
            if node.counter
                counter = visit(node.counter, context)
                range.each do |value|
                    context[counter] = value
                    visit(node.body, context)
                end
            else
                range.each { visit(node.body, context) }
            end
        elsif condition.is_a?(AST_Compare)
            while visit(node.condition, context)
                visit(node.body, context)
            end
        end
    end

    def visit_ast_range(node, context)
        start = visit(node.start, context)
        stop = visit(node.stop, context)
        start..stop
    end

    def visit_ast_compare(node, context)
        left = visit(node.left, context)
        right = visit(node.right, context)
        left.send(node.op, right)
    end

    def visit_ast_block(node, context)
        block_context = context.clone
        node.body.each do |child|
            result = visit(child, block_context)
            return result if child.is_a?(AST_Return)
        end
    end

    def visit_ast_array(node, context)
        node.elements.map { |element| visit(element, context) }
    end

    def visit_ast_dict(node, context)
        node.pairs.map { |key, value| [visit(key, context), visit(value, context)] }.to_h
    end

    def visit_ast_subscript(node, context)
        value = visit(node.value, context)
        index = visit(node.index, context)

        case node.ctx
        when :load then value[index]
        when :store then [value, index]
        end
    end

    def visit_ast_return(node, context) = visit(node.value, context)

    def visit_ast_variable(node, context) = context[node.name]

    def visit_integer(node, context) = node

    def visit_string(node, context) = node
end