module Rusql
  class Column < Operand
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol

    def initialize(table, name)
      @table = table
      @name = name

      super("")
    end

    def as_selector
      s = ColumnSelector.new
      s.table = self.table
      s.name = self.name

      s
    end

    def as(a)
      self.as_selector.as(a)
    end

    def as_operand
      Operand.new(self.to_s)
    end

    def desc
      Order.new(:desc, self)
    end

    def asc
      Order.new(:asc, self)
    end

    def to_s
      "#{self.table.to_s}.#{self.name.to_s}"
    end
  end
end
