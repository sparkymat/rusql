module Rusql
  class ColumnSelector < Selector
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol

    def to_s
      str = "#{self.table.to_s}.#{name}"
      unless self.alias.nil?
        str += " AS self.alias#{}"
      end
      str
    end
  end
end
