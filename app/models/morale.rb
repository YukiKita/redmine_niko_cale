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
    return level_name(@cached_level) if @cached_level
    average = @feelings.inject(0) {|result, feeling| result += feeling[:level]} / @feelings.size.to_f
    count =  Feeling.levels.length
    1.upto(count) do |index|
      if average <= ((count - 1) / count.to_f) * index
        @cached_level = (index - 1)
        return level_name(@cached_level)
      end
    end
    raise "must not happen"
  end
end
