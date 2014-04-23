

Trigger.new do |t|
  t[:id] = 'randbats_moves'
  
  t.match { |info|
    info[:where] == 's' && info[:what] =~ /\A!rmov (.*?)\z/ && $1
  }
  
  t.act do |info|
    mon = info[:result]
    moves = (Pokedex::FORMATSDATA[mon]['viableMoves'] || Pokedex::FORMATSDATA[mon]['learnset'])
    
    info[:respond].call(moves.to_s)
  end
  
end