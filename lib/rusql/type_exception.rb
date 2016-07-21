module Rusql
  class TypeException < Exception 
    def initialize(expected, actual)
      super("Expected: #{expected.name}. Got: #{actual.name}")
    end
  end
end
