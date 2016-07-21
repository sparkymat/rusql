module Rusql
  class Selector
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol

    def to_s
      "#{self.table.to_s}.#{name}"
    end
  end
end
