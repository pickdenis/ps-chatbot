require "./showderp/speaker/markovchains.rb"

Trigger.new do |t|
  t.match { |info|
    (info[:where] == 'c') && info[:what]
  }
  
  t[:chain] = Markov::Chain.new
  
  t.act do |info|
    text = info[:result]
    
    name = $login[:name]
    
    if text[0..name.size-1] == name && text[name.size] == ','
      next if info[:who] == $login[:name]
    
      words = text[name.size..-1].split(' ')
      seed = nil
      
      chain.nodes.each do |keys, values|
        if words.any? { |word| keys.index(word) }
          seed = keys
          break
        end
      end
      
      info[:respond].call("#{chain.generate(10, seed).join(' ')}.".capitalize)
    else
      chain.add_words(text)
    end
  end
end