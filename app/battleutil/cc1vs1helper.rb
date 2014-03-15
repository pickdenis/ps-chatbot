require_relative 'typechart.rb'

module CC1vs1
  
  # Never use these
  BLACKLIST = %w{
    focuspunch
    
    fakeout
    
    return
    frustration
    
    snore
    dreameater
    
    lastresort
    
    explosion
    selfdestruct
    
    synchronoise
    
    belch
    
    trumpcard
    wringout
  }
  
  # Can be used, but their scores will be halved
  BADLIST = %w{
    gigaimpact
    hyperbeam
    rockwrecker
    frenzyplant
    hydrocannon
    blastburn
    roaroftime
    
    skyattack
    solarbeam
    freezeshock
    
    doomdesire
    futuresight 
    
    leafstorm
    overheat
    dracometeor
    psychoboost
    superpower
    hammerarm
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
    
    if BADLIST.index(move)
      score /= 2.0
    end
    
    score *= move_h['accuracy']/100.0 if move_h['accuracy'].is_a? Numeric
    score *= species_h['baseStats'][category == 'Physical' ? 'atk' : 'spa']
    
    # This should be dampened - Pokemon such as Talonflame give a huge boost to rock moves, boosting the score of
    # bad pokemon that happen to have them.
    
    score *= otherteam_h.map { |poke| (TypeChart.effectiveness(move_h['type'], poke['types']) - 1)/2.0 + 1 }.reduce(:*)
    
    # And finally, abilities
    my_abilities = species_h['abilities'].values
    
    if (my_abilities.index('Huge Power') || my_abilities.index('Pure Power')) && move_h['category'] == 'Physical'
      # Note: This is an APPROXIMATION. Because this calculation uses the BASE stat instead of the 
      # calculated stat, this won't be accurate because pure/huge power doesn't double the base stat.
      # For all of the pokemon it affects, it usually almost triples the effective base stat.
      score *= 3
      
    end
    
    otherteam_h.each do |poke|
      abilities = poke['abilities'].values
      
      if !my_abilities.index('Mold Breaker')
      
        if abilities.index('Levitate')
          score = 0 if move_h['type'] == 'Ground'
        end
        
        if abilities.index('Flash Fire')
          score = 0 if move_h['type'] == 'Fire'
        end
        
        if abilities.index('Water Absorb') || abilities.index('Storm Drain') || abilities.index('Dry Skin')
          score = 0 if move_h['type'] == 'Water'
        end
        
        if abilities.index('Volt Absorb') || abilities.index('Motor Drive') || abilities.index('Lightningrod')
          score = 0 if move_h['type'] == 'Electric'
        end
        
        if abilities.index('Sap Sipper')
          score = 0 if move_h['type'] == 'Grass'
        end
        
        if abilities.index('Soundproof')
          score = 0 if ['Hyper Voice', 'Uproar', 'Boomburst', 'Bug Buzz', 'Chatter', 'Relic Sound', 'Echoed Voice'].index(move_h['name'])
        end
        
        if abilities.index('Wonder Guard')
          score = 0 if TypeChart.effectiveness(move_h['type'], poke['types']) <= 1
        end
      end
      
    end
    
    score
  end
  
  
  
end