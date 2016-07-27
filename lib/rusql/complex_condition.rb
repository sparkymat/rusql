module Rusql
  class ComplexCondition < Condition
    attr_reader :type
    attr_reader :conditions

    TYPES = %i(
      and
      or
    )

    def initialize
      @conditions = []
    end

    def add_condition(c)
      raise TypeException.new(Condition, c.class) unless c.is_a?(Condition)

      @conditions << c
    end

    def type=(t)
      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(", ") }") unless TYPES.include?(t)

      @type = t
    end

    def and(condition)
      new_condition = ComplexCondition.new
      new_condition.type = :and

      if self.type == :and
        self.conditions.each do |c|
          new_condition.add_condition(c)
        end
      else
        new_condition.add_condition(self)
      end
      new_condition.add_condition(condition)

      new_condition
    end

    def or(condition)
      new_condition = ComplexCondition.new
      new_condition.type = :or

      if self.type == :or
        self.conditions.each do |c|
          new_condition.add_condition(c)
        end
      else
        new_condition.add_condition(self)
      end
      new_condition.add_condition(condition)

      new_condition
    end

    def to_s(indent_level: 1, multiline: true)
      if multiline
        indent = "  "*indent_level
        indent_out = "  "*(indent_level-1)
        "(\n" + indent + self.conditions.map{ |c| c.to_s(indent_level: indent_level+1, multiline: true) }.join("\n#{indent}#{self.type.to_s.upcase} ") + "\n#{indent_out})"
      else
        self.conditions.map{ |c| c.to_s(indent_level: indent_level, multiline: multiline) }.join(" #{self.type.to_s.upcase} ")
      end
    end
  end
end
