Trigger.new do |t|
  t[:id] = 'randbats_moves'
  
  t.match { |info|
    info[:what] =~ /\A!rmove? (.*?)\z/ && $1
  }
  
  t.act do |info|
    mon = CBUtils.condense_name(info[:result])

    if Pokedex::FORMATSDATA[mon].nil?
    	result = ""
    else
    	moves = (Pokedex::FORMATSDATA[mon]['viableMoves'] || Pokedex::FORMATSDATA[mon]['learnset'])
    	result = moves.keys.map { |m| Pokedex::MOVES[m]['name'] }.join(', ')
    end

    info[:respond].call(result)
  end
  
end
