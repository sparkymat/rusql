module Rusql
  class Table
    typed_attr_accessor :name, Symbol
    attr_reader :alias

    def [](ind)
      Column.new(self, ind)
    end

    def as(name)
      raise TypeException.new(Symbol, name.class) unless name.is_a?(String) || name.is_a?(Symbol)

      @alias = name

      self
    end

    def to_s
      if self.alias.nil?
        self.name
      else
        self.alias
      end
    end

    def to_s_for_aliasing
      if self.alias.nil?
        "#{self.name}"
      else
        "#{self.name} AS #{self.alias}"
      end      
    end
  end
end
