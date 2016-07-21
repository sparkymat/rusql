module Rusql
  class Operand
    def initialize(op)
      raise TypeException.new(String, op.class) unless op.is_a?(String)
      @op = op
    end

    %i(greater_than greater_than_or_equals less_than less_than_or_equals equals not_equals).each do |type|
      define_method type, Proc.new { |v|
        c = BasicCondition.new
        c.type = type
        c.left = self
        c.right = v

        c
      }
    end

    %i(in not_in).each do |type|
      define_method type, Proc.new { |v|
        raise TypeException.new(Array, v.class) unless v.is_a?(Array) || v.is_a?(Range)

        c = BasicCondition.new
        c.type = type
        c.left = self
        c.right = v.to_a
        
        c
      }
    end

    def like(v)
      raise TypeException.new(String, v.class) unless v.is_a?(String)

      c = BasicCondition.new
      c.type = :like
      c.left = self
      c.right = v
      
      c
    end

    def to_s
      @op
    end
  end
end
