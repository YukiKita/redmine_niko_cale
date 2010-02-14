class Mood < Feeling
  def add feeling
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
    average = @feelings.inject(0) {|result, feeling| result += feeling.level} / @feelings.size.to_f
    count = FEELING_TYPES.size
    1.upto(count) do |i|
      if average <= ((count - 1) / count.to_f) * i
        return (i - 1)
      end
    end
  end
end
