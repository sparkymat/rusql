module Rusql
  class ConvertTzFunctionOperand < Operand
    def initialize(op, from, to)
      raise TypeException.new(String, from.class) unless from.is_a?(String)
      raise TypeException.new(String, to.class) unless to.is_a?(String)

      op_string = case op
                  when Column
                    op.as_operand.to_s
                  else
                    op.to_s
                  end

      super("CONVERT_TZ(#{ op_string }, #{ convert_value(from) }, #{ convert_value(to) })")
    end
  end
end
