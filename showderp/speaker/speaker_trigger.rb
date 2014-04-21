require "./showderp/speaker/markovchains.rb"

Trigger.new do |t|
  t.match { |info|
    (info[:where] == 'c' || info[:where] == 'pm') && info[:what]
  }
  
  chain = Markov::Chain.new
  
  t.act do |info|
    text = info[:result]
    
    chain.add_words(text)
    
    next if !(text =~ /#{$login[:name].downcase},\s+(.*?)/i)
    
    words = $1.split(' ')
    seed = nil
    
    chain.nodes.each do |keys, values|
      if words.any? { |word| keys.index(word) }
        seed = keys
        break
      end
    end
    
    info[:respond].call("#{chain.generate(10, seed).join(' ')}.".capitalize)
    
  end
end