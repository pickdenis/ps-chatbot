require_relative 'typechart.rb'

module CC1vs1
  
  BLACKLIST = %w{
    focuspunch
    
    dynamicpunch
    zapcannon
    inferno
    
    gigaimpact
    hyperbeam
    rockwrecker
    frenzyplant
    hydrocannon
    blastburn
    
    solarbeam
    skyattack
    
    fakeout
    
    return
    frustration
    
    snore
    dreameater
    
  }
  
  def self.calculate_move_score species, move, otherteam 
    # Note: all of these arguments should be strings. All pokemon should be specified
    # by their species name (eg. Rufflet, not rufflet) and the move must be given by
    # its ID (eg. focuspunch, not Focus Punch)
    return 0 if BLACKLIST.index(move)
    
    score = 1
    
    move_h = Pokedex::MOVES[move]
    return 0 if !move_h
    
    category = move_h['category']
    return 0 if category == 'Status'
    
    plist = Pokedex::POKEMONDATA.values
    
    species_h = plist.find { |poke| poke['name'] == species }
    otherteam_h = otherteam.map { |teampoke| plist.find { |poke| poke['name'] == teampoke } }
    
    score *= 1.5 if (species_h['types'].index(move_h['type']))
    
    score *= move_h['basePower']
    score *= species_h['baseStats'][category == 'Physical' ? 'atk' : 'spa']
    score *= otherteam_h.map { |poke| TypeChart.effectiveness(move_h['type'], poke['types']) }.reduce(:*)
    
    score
  end
  
  
  
end