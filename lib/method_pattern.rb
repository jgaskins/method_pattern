require "method_pattern/version"

module MethodPattern
  def defn name, &definition
    fn = PatternMatchedFunction.new(name)
    fn.instance_exec(&definition)

    define_method name do |*args, &block|
      instance_exec(*args, &fn.match(args))
    rescue => e
      raise e, e.message, caller[2..-1]
    end
  end

  class PatternMatchedFunction
    def initialize name
      @name = name
      @patterns = []
      @default = proc do |*args|
        raise ArgumentError,
          "method #{self.class.inspect}##{name} does not know how to handle arguments: #{args.map(&:inspect).join(', ')}"
      end
    end

    def with *patterns, &block
      @patterns << Pattern.new(patterns, block)
    end

    def match args
      @patterns.each do |pattern|
        if pattern.match? args
          return pattern.block
        end
      end

      @default
    end

    class Pattern
      attr_reader :accepted, :block

      def initialize accepted, block
        @accepted = accepted
        @block = block
      end

      def match? args
        @accepted.each_with_index do |pattern, index|
          return false unless match_arg?(pattern, args[index])
        end

        true
      end

      def match_arg? pattern, arg
        case pattern
        when Hash
          return false unless arg.is_a? Hash

          pattern.each do |key, value|
            return false unless arg.key?(key) && match_arg?(value, arg[key])
          end

          true
        else
          pattern === arg
        end
      end
    end
  end
end
