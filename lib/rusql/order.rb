module Rusql
  class Order
    attr_reader :type
    attr_reader :column

    TYPES =%i(
      asc
      desc
    )

    def initialize(type, column)
      raise Exception.new("Expected type to be one of #{}") unless TYPES.include?(type)
      raise TypeException.new(Column, column.class) unless column.is_a?(Column)

      @type = type
      @column = column
    end

    def to_s
      "#{self.column.to_s} #{type.to_s.upcase}"
    end
  end
end
