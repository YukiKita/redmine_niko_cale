class Morale < Feeling
  def << feeling
    if feeling.at == self.at
      @feelings ||= []
      @feelings << feeling
      true
    else
      false
    end
  end
  def level
    return nil unless @feelings
    return @cached_level if @cached_level
    average = @feelings.inject(0) {|result, feeling| result += feeling.level} / @feelings.size.to_f
    count = FEELING_TYPES.size
    1.upto(count) do |i|
      if average <= ((count - 1) / count.to_f) * i
        @cached_level = (i - 1)
        return @cached_level
      end
    end
    raise "must not happen"
  end
end
