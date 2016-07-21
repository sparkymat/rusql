module Rusql
  class CountSelector < Selector
    attr_reader :field

    def initialize(field)
      @field = field
    end

    def to_s
      str = "COUNT(#{ self.field })"
      unless self.alias.nil?
        str += " AS self.alias#{}"
      end
      str
    end
  end
end
