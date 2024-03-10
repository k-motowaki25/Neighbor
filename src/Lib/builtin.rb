class Builtin
    def self.builtin_print(*args)
        args = args.map { |arg| arg.is_a?(Array) ? arg.inspect : arg.to_s }
        puts args.join(' ')
    end

    def self.builtin_input(prompt="")
        print prompt
        STDIN.gets.chomp
    end

    def self.builtin_length(value)
        value.length
    end

    def self.builtin_int(value)
        value.to_i
    end
end