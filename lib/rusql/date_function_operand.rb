module Rusql
  class DateFunctionOperand < Operand
    def initialize(op)
      super("DATE(#{ op.to_s })")
    end
  end
end
