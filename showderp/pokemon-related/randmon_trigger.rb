require './showderp/pokemon-related/pokedata.rb'

Trigger.new do |t|
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    (info[:what][0..5] == '!rmon ' && info[:what][6..-1].split(' ').map(&:strip)) ||
    (info[:what][0..4] == '!rmon' && []) 

  }
  
  t.act do |info|
    p info[:result]
    t[:lastused] + t[:cooldown] < Time.now or next
    t[:lastused] = Time.now
    
    # aliases
    args = info[:result]
    mondata = Pokedex::POKEMONDATA
    fdata = Pokedex::FORMATSDATA
    
    # this will hold the selected mons
    result = []
    
    num, tier, arg1 = nil
    if (arg1 = args.shift).to_i > 0
      tier = (args.shift || 'ANY')
      num = arg1.to_i
    else
      tier = (arg1 || 'ANY')
      num = 1
    end
    
    num <= 6 or next
    
    tiers = ['UBER', 'OU', 'UU', 'RU', 'NU', 'LC', 'CAP', 'BL', 'BL2', 'BL3', 'NFE']
    tier = "ANY" if !tiers.index(tier.upcase) 
    num.times do
      mon = mondata.keys.sample
      redo if fdata[mon].nil?
      redo if (montier = fdata[mon]['tier']).nil?
      redo if tiers.index(tier.upcase) && montier.upcase != tier.upcase
      
      result << mondata[mon]['name']
    end
    
    info[:respond].call("(#{info[:who]}) #{result.join(', ')} (tier=#{tier.upcase})")
  end
end
