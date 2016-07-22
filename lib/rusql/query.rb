module Rusql
  class Query
    attr_reader :selectors
    attr_reader :joins
    attr_reader :from_table
    attr_reader :condition
    attr_reader :orders
    attr_reader :limit

    def initialize(selectors)
      selectors.each do |selector|
        raise TypeException.new(Selector, selector.class) unless selector.is_a?(Selector)
      end

      @selectors = selectors
      @joins = []
      @orders = []
    end

    def select(*selectors)
      selectors.each do |selector|
        raise TypeException.new(Selector, selector.class) unless selector.is_a?(Selector)
      end

      @selectors = selectors

      self
    end

    def limit(c)
      raise TypeException unless c.is_a?(Fixnum)

      @limit = c

      self
    end

    def from(t)
      raise TypeException unless t.is_a?(Table)

      @from_table = t

      self
    end

    def inner_join(table,condition)
      self.joins << Join.new(:inner_join, table, condition)

      self
    end

    def outer_join(table,condition)
      self.joins << Join.new(:outer_join, table, condition)

      self
    end

    def left_outer_join(table,condition)
      self.joins << Join.new(:left_outer_join, table, condition)

      self
    end

    def right_outer_join(table,condition)
      self.joins << Join.new(:right_outer_join, table, condition)

      self
    end

    def where(condition)
      raise TypeException.new(Condition, condition.class) unless condition.is_a?(Condition)

      @condition = condition

      self
    end

    def order_by(*orders)
      orders.each do |o|
        raise TypeException.new(Order, o.class) unless o.is_a?(Order)
      end

      @orders = orders

      self
    end

    def to_s
      join_part = self.joins.map{ |j| "\n#{j.to_s}" }.join
      where_part = "\nWHERE"
      order_part = "\nORDER BY #{ self.orders.map(&:to_s).join(", ") }"

      if self.condition.is_a?(BasicCondition)
        where_part += " "
        where_part += self.condition.to_s
      elsif self.condition.is_a?(ComplexCondition)
        where_part += "\n  "
        where_part += self.condition.to_s
      end

      <<-EOS
SELECT
#{ self.selectors.map{ |s| "  #{s.to_s}" }.join(",\n") }
FROM #{ self.from_table.to_s_for_aliasing }#{ (self.joins.length > 0) ? join_part : ""  }#{ self.condition.nil? ? "" : where_part }#{ self.orders.length > 0 ? order_part : "" }
      EOS
    end
  end
end
