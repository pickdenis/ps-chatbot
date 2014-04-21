module Markov
  
  
  class Chain
    attr_accessor :nodes, :keysize
    
    def initialize elements=[], keysize=2
      @keysize = keysize
      @nodes = {}
      add_to_nodes(elements)
    end
    
    def add_to_nodes elements
      
      (0..elements.size - keysize - 1).each do |index|
        
        node = (@nodes[elements[index..index + keysize - 1]] ||= [])
        
        node << elements[index + keysize]
      end
      
      self
    end
    
    def add_words text
      text.strip!
      text.gsub!(',', '')
      
      if ['.', '?'].index(text[-1])
        text = text[0..-2]
      end
      
      add_to_nodes(text.split(' '))
      
      self
    end
    
    def generate howmany, seed=nil
      if !seed
        seed = @nodes.keys.sample
      end
      current_key = seed
      result = []
      
      until result.size >= howmany || !@nodes[current_key]
        result << @nodes[current_key].sample
        current_key.shift
        current_key << result.last
      end
      
      return result
    end
  end
end 

if $0 == __FILE__
  c = Markov::Chain.new
  c.add_words("Hi my name is Bob and I am a robot")
  c.add_words("Hi my name is Julie and I live in a house")
  
  p c.generate(10)
end