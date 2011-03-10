class String

  def to_trigrams
    trigrams = Set.new()
    self.split.each do |p|
        word = '  ' + p.downcase + '  '
        (0..word.length - 3).each do |idx|
            trigrams.add(word[idx, 3])
        end
    end
    trigrams.to_a
  end

  def remove_all(ignores)
    s = self
    ignores.each do |i|
      s = s.gsub(i,'')
    end
    s.strip.gsub(/\s+/,' ')
  end

end