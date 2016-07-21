require "rusql/version"

class Class
  def typed_attr_accessor(name, type)
    raise TypeException.new(Class, type.class) unless type.is_a?(Class)

    instance_eval { attr_reader name }
    
    define_method "#{name}=", Proc.new { |val|
      instance_variable_set("@#{name}", val)
    }
  end 
end

module Rusql
  def convert_value(v)
    case v
    when String
      "'#{v}'"
    when DateTime
      v.strftime("'%Y-%m-%d %H:%M:%S'")
    else
      v.inspect
    end
  end
  
  class Table
    typed_attr_accessor :name, Symbol

    def [](ind)
      c = Column.new
      c.table = self
      c.name = ind

      c
    end

    def to_s
      "#{name}"
    end
  end

  class TypeException < Exception 
    def initialize(expected, actual)
      super("Expected: #{expected.name}. Got: #{actual.name}")
    end
  end

  class Selector
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol

    def to_s
      "#{self.table.to_s}.#{name}"
    end
  end

  class Column
    typed_attr_accessor :table, Table
    typed_attr_accessor :name, Symbol

    def as_selector
      s = Selector.new
      s.table = self.table
      s.name = self.name

      s
    end

    %i(greater_than greater_than_or_equals less_than less_than_or_equals equals not_equals).each do |type|
      define_method type, Proc.new { |v|
        c = BasicCondition.new
        c.type = type
        c.left = self
        c.right = v

        c
      }
    end

    %i(in not_in).each do |type|
      define_method type, Proc.new { |v|
        raise TypeException.new(Array, v.class) unless v.is_a?(Array) || v.is_a?(Range)

        c = BasicCondition.new
        c.type = type
        c.left = self
        c.right = v.to_a
        
        c
      }
    end

    def like(v)
      raise TypeException.new(String, v.class) unless v.is_a?(String)

      c = BasicCondition.new
      c.type = :like
      c.left = self
      c.right = v
      
      c
    end

    def to_s
      "#{self.table.to_s}.#{name}"
    end
  end

  class InnerJoin
    typed_attr_accessor :from_column, Column
    typed_attr_accessor :to_column, Column

    def to_s
      "INNER JOIN #{self.from_column.table.to_s} ON #{self.from_column.to_s} = #{self.to_column.to_s}"
    end
  end
  
  class Condition
  end

  class BasicCondition < Condition
    attr_reader :type
    typed_attr_accessor :left, Column
    attr_accessor :right

    TYPES = %i(
      equals
      greater_than
      greater_than_or_equals
      in
      less_than
      less_than_or_equals
      like
      not_equals
      not_in
    )

    def type=(t)
      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(", ") }") unless TYPES.include?(t)

      @type = t
    end

    def and(condition)
      raise Exception.new(Condition, condition.class) unless condition.is_a?(Condition)

      c = ComplexCondition.new
      c.type = :and
      c.add_condition(self)
      c.add_condition(condition)

      c
    end

    def to_s(indent: " ") # to make it compatible with complex condition to_s
      case self.type
      when :equals
        "#{left.to_s} = #{convert_value(self.right)}"
      when :greater_than
        "#{left.to_s} > #{convert_value(self.right)}"
      when :greater_than_or_equals
        "#{left.to_s} >= #{convert_value(self.right)}"
      when :in
        "#{left.to_s} IN (#{ self.right.map{|v| convert_value(v) }.join(", ") })"
      when :less_than
        "#{left.to_s} < #{convert_value(self.right)}"
      when :less_than_or_equals
        "#{left.to_s} <= #{convert_value(self.right)}"
      when :like
        "#{left.to_s} LIKE #{convert_value(self.right)}"
      when :not_equals
        "#{left.to_s} != #{convert_value(self.right)}"
      when :not_in
        "#{left.to_s} NOT IN (#{ self.right.map{|v| convert_value(v) }.join(", ") })"
      end
    end
  end

  class ComplexCondition < Condition
    attr_reader :type
    attr_reader :conditions

    TYPES = %i(
      and
      or
    )

    def initialize
      @conditions = []
    end

    def add_condition(c)
      raise TypeException.new(Condition, c.class) unless c.is_a?(Condition)

      @conditions << c
    end

    def type=(t)
      raise Exception.new("Expected type to be one of #{ TYPES.map(&:to_s).join(", ") }") unless TYPES.include?(t)

      @type = t
    end

    def and(condition)
      new_condition = ComplexCondition.new
      new_condition.type = :and

      if self.type == :and
        self.conditions.each do |c|
          new_condition.add_condition(c)
        end
      else
        new_condition.add_condition(self)
      end
      new_condition.add_condition(condition)

      new_condition
    end

    def or(condition)
      new_condition = ComplexCondition.new
      new_condition.type = :or

      if self.type == :or
        self.conditions.each do |c|
          new_condition.add_condition(c)
        end
      else
        new_condition.add_condition(self)
      end
      new_condition.add_condition(condition)

      new_condition
    end

    def to_s(indent: "  ")
      self.conditions.map{ |c| c.to_s(indent: indent+"  ") }.join("\n#{indent}#{self.type.to_s.upcase} ")
    end
  end

  class Query
    attr_reader :selectors
    attr_reader :joins
    attr_reader :from_table
    attr_reader :condition

    def initialize(selectors)
      selectors.each do |selector|
        raise TypeException.new(Selector, selector.class) unless selector.is_a?(Selector)
      end

      @selectors = selectors
      @joins = []
    end

    def from(t)
      raise TypeException unless t.is_a?(Table)

      @from_table = t

      self
    end

    def inner_join(from,to)
      j = InnerJoin.new
      j.from_column = from
      j.to_column = to

      self.joins << j

      self
    end

    def where(condition)
      raise TypeException.new(Condition, condition.class) unless condition.is_a?(Condition)

      @condition = condition

      self
    end

    def to_s
      join_part = self.joins.map{ |j| "\n#{j.to_s}" }.join
      where_part = "\nWHERE"

      if self.condition.is_a?(BasicCondition)
        where_part += " "
        where_part += self.condition.to_s
      elsif self.condition.is_a?(ComplexCondition)
        where_part += "\n  "
        where_part += self.condition.to_s
      end

      <<-EOS
SELECT
#{ self.selectors.map{ |s| "  #{s.to_s}" }.join(",\n") }
FROM #{ self.from_table.to_s }#{ (self.joins.length > 0) ? join_part : ""  }#{ self.condition.nil? ? "" : where_part }
      EOS
    end
  end

  def table(name)
    t = Table.new
    t.name = name
    t
  end

  def select(*opts)
    opts.each do |arg|
      raise TypeException.new(Selector, arg.class) unless arg.is_a?(Selector) || arg.is_a?(Column)
    end

    Query.new(opts.map{|a| a.is_a?(Column) ? a.as_selector : a })
  end
end
