Trigger.new do |t|
  t[:id] = 'randbats_moves'
  
  t.match { |info|
    info[:what] =~ /\A!rmove? (.*?)\z/ && $1
  }
  
  t.act do |info|
    mon = CBUtils.condense_name(info[:result])

    fd = Pokedex::FORMATSDATA[mon]
    if !fd || !(moves = fd['randomBattleMoves'] || fd['learnset']) 
      result = ""
    else
      result = moves.map { |m| Pokedex::MOVES[m]['name'] }.join(', ')
    end

    info[:respond].call(result)
  end
  
end
