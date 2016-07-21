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

def convert_value(v)
  case v
  when String
    "'#{v}'"
  when Date
    v.strftime("'%Y-%m-%d'")
  when DateTime
    v.strftime("'%Y-%m-%d %H:%M:%S'")
  else
    v.inspect
  end
end

module Rusql
  def date(value)
    DateFunctionOperand.new(value)
  end

  def convert_tz(value, from, to)
    ConvertTzFunctionOperand.new(value, from, to)
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

require "rusql/operand"
require "rusql/table"
require "rusql/column"
require "rusql/selector"
require "rusql/query"
require "rusql/join"
require "rusql/convert_tz_function_operand"
require "rusql/date_function_operand"
require "rusql/condition"
require "rusql/basic_condition"
require "rusql/complex_condition"
