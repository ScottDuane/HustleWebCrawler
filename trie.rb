class Trie
  def initialize
    @trie = {}
  end

  def insert(str)
    layer = @trie

    chars = str.chars
    chars.each do |char|
      if layer[char]
        layer = layer[char]
      else
        layer[char] = {}
        layer = layer[char]
      end
    end
  end

  def lookup(str)
    layer = @trie

    chars = str.chars
    chars.each do |char|
      return false unless layer[char]
      layer = layer[char]
    end

    true
  end
end
