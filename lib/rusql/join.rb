module Rusql
  class Join
    attr_reader :type
    typed_attr_accessor :table, Table
    typed_attr_accessor :condition, BasicCondition

    TYPES = %i(
      inner_join
      left_outer_join
      outer_join
    )

    def initialize(type, table, condition)
      final_table = table.is_a?(Table) ? table : ( table.respond_to?(:as_rusql_table) ? table.as_rusql_table : nil )

      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(",") }") unless TYPES.include?(type)
      raise TypeException.new(Table, table.class) if final_table.nil?
      raise TypeException.new(BasicCondition, condition.class) unless condition.is_a?(BasicCondition)

      @type = type
      @table = final_table
      @condition = condition
    end

    def to_s
      "#{ self.type.to_s.upcase.gsub("_"," ") } #{self.table.to_s_for_aliasing} ON #{self.condition.to_s}"
    end
  end
end
