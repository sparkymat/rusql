module Rusql
  class Selector
    typed_attr_accessor :alias, Symbol

    def as(a)
      raise TypeException.new(Symbol, a.class) unless a.is_a?(Symbol)

      @alias = a

      self
    end
  end
end
