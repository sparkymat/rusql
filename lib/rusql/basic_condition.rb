module Rusql
  class BasicCondition < Condition
    attr_reader :type
    typed_attr_accessor :left, Operand
    attr_accessor :right

    TYPES = %i(
      equals
      greater_than
      greater_than_or_equals
      in
      less_than
      less_than_or_equals
      like
      not_equals
      not_in
    )

    def type=(t)
      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(", ") }") unless TYPES.include?(t)

      @type = t
    end

    def and(condition)
      raise TypeException.new(Condition, condition.class) unless condition.is_a?(Condition)

      c = ComplexCondition.new
      c.type = :and
      c.add_condition(self)
      c.add_condition(condition)

      c
    end

    def or(condition)
      raise TypeException.new(Condition, condition.class) unless condition.is_a?(Condition)

      c = ComplexCondition.new
      c.type = :or
      c.add_condition(self)
      c.add_condition(condition)

      c
    end

    def to_s(indent_level: 1) # to make it compatible with complex condition to_s
      case self.type
      when :equals
        "#{left.to_s} = #{convert_value(self.right)}"
      when :greater_than
        "#{left.to_s} > #{convert_value(self.right)}"
      when :greater_than_or_equals
        "#{left.to_s} >= #{convert_value(self.right)}"
      when :in
        "#{left.to_s} IN (#{ self.right.map{|v| convert_value(v) }.join(", ") })"
      when :less_than
        "#{left.to_s} < #{convert_value(self.right)}"
      when :less_than_or_equals
        "#{left.to_s} <= #{convert_value(self.right)}"
      when :like
        "#{left.to_s} LIKE #{convert_value(self.right)}"
      when :not_equals
        "#{left.to_s} != #{convert_value(self.right)}"
      when :not_in
        "#{left.to_s} NOT IN (#{ self.right.map{|v| convert_value(v) }.join(", ") })"
      end
    end
  end
end
