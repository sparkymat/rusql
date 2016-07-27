module Rusql
  class Query
    def initialize(selectors)
      selectors.each do |selector|
        raise TypeException.new(Selector, selector.class) unless selector.is_a?(Selector)
      end

      @selectors = selectors
      @joins = []
      @orders = []
      @group_by = nil
    end

    def duplicate
      new_one = Query.new(self.instance_variable_get(:@selectors))
      new_one.instance_variable_set( :@condition,  self.instance_variable_get(:@condition)  )
      new_one.instance_variable_set( :@from_table, self.instance_variable_get(:@from_table) )
      new_one.instance_variable_set( :@group_by,   self.instance_variable_get(:@group_by)   )
      new_one.instance_variable_set( :@joins,      self.instance_variable_get(:@joins)      )
      new_one.instance_variable_set( :@limit,      self.instance_variable_get(:@limit)      )
      new_one.instance_variable_set( :@orders,     self.instance_variable_get(:@orders)     )

      new_one
    end

    def select(*selectors)
      selectors.each do |selector|
        raise TypeException.new(Selector, selector.class) unless selector.is_a?(Selector)
      end

      new_one = self.duplicate
      new_one.instance_variable_set(:@selectors, selectors)

      new_one
    end

    def limit(c)
      raise TypeException.new(Fixnum, c.class) unless c.is_a?(Fixnum)

      new_one = self.duplicate
      new_one.instance_variable_set(:@limit, c)

      new_one
    end

    def from(t)
      raise TypeException.new(Table, t.class) unless t.is_a?(Table)

      new_one = self.duplicate
      new_one.instance_variable_set(:@from_table, t)

      new_one
    end

    def group_by(c)
      raise TypeException.new(Column, c.class) unless c.is_a?(Column)

      new_one = self.duplicate
      new_one.instance_variable_set(:@group_by, c)

      new_one
    end

    def join(join)
      raise TypeException.new(Join, join.class) unless join.is_a?(Join)

      new_one = self.duplicate
      joins = new_one.instance_variable_get(:@joins)
      joins << join
      new_one.instance_variable_set(:@joins, joins)

      new_one
    end

    %i(inner_join outer_join left_outer_join right_outer_join).each do |jm|
      define_method jm, Proc.new { |table, condition|
        new_one = self.duplicate
        joins = new_one.instance_variable_get(:@joins)
        joins << Join.new(jm, table, condition)
        new_one.instance_variable_set(:@joins, joins)

        new_one
      }
    end

    def where(condition)
      raise TypeException.new(Condition, condition.class) unless condition.is_a?(Condition)

      new_one = self.duplicate
      new_one.instance_variable_set(:@condition, condition)

      new_one
    end

    def order_by(*orders)
      orders.each do |o|
        raise TypeException.new(Order, o.class) unless o.is_a?(Order)
      end

      new_one = self.duplicate
      new_one.instance_variable_set(:@orders, orders)

      new_one
    end

    def to_s
      join_part = @joins.map{ |j| "\n#{j.to_s}" }.join
      where_part = "\nWHERE"
      order_part = "\nORDER BY #{ @orders.map(&:to_s).join(", ") }"
      group_by_part = "\nGROUP BY #{ @group_by&.to_s }"

      if @condition.is_a?(BasicCondition)
        where_part += " "
        where_part += @condition.to_s
      elsif @condition.is_a?(ComplexCondition)
        where_part += " "
        where_part += @condition.to_s
      end

      <<-EOS
SELECT
#{ @selectors.map{ |s| "  #{s.to_s}" }.join(",\n") }
FROM #{ @from_table.to_s_for_aliasing }#{ (@joins.length > 0) ? join_part : ""  }#{ @condition.nil? ? "" : where_part }#{ @orders.length > 0 ? order_part : "" }#{ @group_by.nil? ? "" : group_by_part }
      EOS
    end
  end
end
