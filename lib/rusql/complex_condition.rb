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

    def to_s(indent: "  ")
      self.conditions.map{ |c| c.to_s(indent: indent+"  ") }.join("\n#{indent}#{self.type.to_s.upcase} ")
    end
  end
end
