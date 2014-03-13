require_relative 'typechart.rb'

module CC1vs1
  
  BLACKLIST = %w{
    focuspunch
    
    
    
    solarbeam
    skyattack
    
    fakeout
    
    return
    frustration
    
    snore
    dreameater
    
    lastresort
    
    explosion
    selfdestruct
    
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
    
    # These look up the species names in the POKEMONDATA table to get a hash
    
    species_h = plist.find { |poke| poke['name'] == species }
    otherteam_h = otherteam.map { |teampoke| plist.find { |poke| (poke||{})['name'] == teampoke } }
    
    # Now, calculate the score
    
    score *= 1.5 if (species_h['types'].index(move_h['type']))
    
    score *= move_h['basePower']
    
    if %w{ gigaimpact hyperbeam rockwrecker frenzyplant hydrocannon blastburn roaroftime }.index(move)
      score /= 2.0
    end
    
    score *= move_h['accuracy']/100.0 if move_h['accuracy'].is_a? Numeric
    score *= species_h['baseStats'][category == 'Physical' ? 'atk' : 'spa']
    
    # This should be dampened - Pokemon such as Talonflame give a huge boost to rock moves, boosting the score of
    # bad pokemon that happen to have them.
    
    score *= otherteam_h.map { |poke| (TypeChart.effectiveness(move_h['type'], poke['types']) - 1)/2.0 + 1 }.reduce(:*)
    
    score
  end
  
  
  
end