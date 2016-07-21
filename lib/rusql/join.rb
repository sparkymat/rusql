module Rusql
  class Join
    attr_reader :type
    typed_attr_accessor :from_column, Column
    typed_attr_accessor :to_column, Column

    TYPES = %i(
      inner_join
      left_outer_join
      outer_join
    )

    def initialize(type, from, to)
      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(",") }") unless TYPES.include?(type)
      raise TypeException.new(Column, from.class) unless from.is_a?(Column)
      raise TypeException.new(Column, to.class) unless to.is_a?(Column)

      @type = type
      @from_column = from
      @to_column = to
    end

    def to_s
      "#{ self.type.to_s.upcase.gsub("_"," ") } #{self.from_column.table.to_s_for_aliasing} ON #{self.from_column.to_s} = #{self.to_column.to_s}"
    end
  end
end
