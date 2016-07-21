module Rusql
  class Column < Operand
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol
    typed_attr_accessor :alias, Symbol

    def initialize(table, name)
      @table = table
      @name = name

      super("")
    end

    def as(a)
      raise TypeException.new(Symbol, a.class) unless a.is_a?(Symbol)

      @alias = a

      self
    end

    def as_selector
      s = Selector.new
      s.table = self.table
      s.name = self.name

      s
    end

    def as_operand
      Operand.new(self.to_s)
    end

    def to_s
      if self.alias.nil?
        "#{self.table.to_s}.#{self.name.to_s}"
      else
        self.alias.to_s
      end
    end
  end
end
