class ASTNode
    def accept(visitor)
        visitor.visit(self)
    end
end


class AST_Module < ASTNode
    attr_accessor :body

    def initialize
        @body = []
    end
end


class AST_BinOp < ASTNode
    attr_accessor :left, :op, :right

    def initialize(left, op, right)
        @left = left
        @op = op
        @right = right
    end
end


class AST_Name < ASTNode
    attr_accessor :id, :ctx

    def initialize(id, ctx=nil)
        @id = id
        @ctx = ctx
    end
end


class AST_Array < ASTNode
    attr_accessor :elements

    def initialize(elements=[])
        @elements = elements
    end
end


class AST_Subscript < ASTNode
    attr_accessor :value, :index, :ctx

    def initialize(value, index, ctx=nil)
        @value = value
        @index = index
        @ctx = ctx
    end
end


class AST_Dict < ASTNode
    attr_accessor :pairs

    def initialize(pairs={})
        @pairs = pairs
    end
end


class AST_Assign < ASTNode
    attr_accessor :target, :value

    def initialize(target, value)
        @target = target
        @value = value
    end
end


class AST_Function < ASTNode
    attr_accessor :name, :args, :body

    def initialize(name, args, body)
        @name = name
        @args = args
        @body = body
    end
end


class AST_Call < ASTNode
    attr_accessor :func, :args

    def initialize(func, args)
        @func = func
        @args = args
    end
end


class AST_If < ASTNode
    attr_accessor :condition, :body, :orelse

    def initialize(condition, body, orelse=[])
        @condition = condition
        @body = body
        @orelse = orelse
    end
end


class AST_Compare < ASTNode
    attr_accessor :left, :op, :right

    def initialize(left, op, right)
        @left = left
        @op = op
        @right = right
    end
end


class AST_Block < ASTNode
    attr_accessor :body

    def initialize(body)
        @body = body
    end
end


class AST_Return < ASTNode
    attr_accessor :value

    def initialize(value)
        @value = value
    end
end


class AST_Loop < ASTNode
    attr_accessor :condition, :body, :counter

    def initialize(condition, body, counter=nil)
        @condition = condition
        @body = body
        @counter = counter
    end
end


class AST_Range < ASTNode
    attr_accessor :start, :stop

    def initialize(start, stop)
        @start = start
        @stop = stop
    end
end