require "rusql/version"
require "rusql/type_exception"

class Class
  def typed_attr_accessor(name, type)
    raise TypeException.new(Class, type.class) unless type.is_a?(Class)

    instance_eval { attr_reader name }
    
    define_method "#{name}=", Proc.new { |val|
      instance_variable_set("@#{name}", val)
    }
  end 
end

def convert_value(v)
  case v
  when String
    "'#{v}'"
  when Date
    v.strftime("'%Y-%m-%d'")
  when DateTime, Time
    v.strftime("'%Y-%m-%d %H:%M:%S'")
  else
    v.to_s
  end
end

module Rusql
  def date(value)
    DateFunctionOperand.new(value)
  end

  def convert_tz(value, from, to)
    ConvertTzFunctionOperand.new(value, from, to)
  end

  def distinct(sel)
    raise TypeException.new(Selector, sel.class) unless sel.is_a?(Selector) || sel.is_a?(Column)
    final_sel = sel.is_a?(Column) ? sel.as_selector : sel
    DistinctFunctionSelector.new(final_sel.to_s)
  end

  def group_concat(sel)
    raise TypeException.new(Selector, sel.class) unless sel.is_a?(Selector) || sel.is_a?(Column)
    final_sel = sel.is_a?(Column) ? sel.as_selector : sel
    GroupConcatFunctionSelector.new(final_sel.to_s)
  end

  def count(col)
    raise TypeException.new(Column, col.class) unless col.is_a?(Column)
    CountSelector.new(col.to_s)
  end

  def count_all
    CountSelector.new("*")
  end

  def table(name)
    t = Table.new
    t.name = name
    t
  end

  def inner_join(table,condition)
    Join.new(:inner_join, table, condition)
  end

  def outer_join(table,condition)
    Join.new(:outer_join, table, condition)
  end

  def left_outer_join(table,condition)
    Join.new(:left_outer_join, table, condition)
  end

  def right_outer_join(table,condition)
    Join.new(:right_outer_join, table, condition)
  end

  def select(*opts)
    opts.each do |arg|
      raise TypeException.new(Selector, arg.class) unless arg.is_a?(Selector) || arg.is_a?(Column)
    end

    Query.new(opts.map{|a| a.is_a?(Column) ? a.as_selector : a })
  end
end

require "rusql/operand"
require "rusql/table"
require "rusql/column"
require "rusql/selector"
require "rusql/column_selector"
require "rusql/count_selector"
require "rusql/query"
require "rusql/convert_tz_function_operand"
require "rusql/date_function_operand"
require "rusql/condition"
require "rusql/basic_condition"
require "rusql/complex_condition"
require "rusql/join"
require "rusql/order"
require "rusql/distinct_function_selector"
require "rusql/group_concat_function_selector"
