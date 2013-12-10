require './showderp/pokemon-related/pokedata.rb'

Trigger.new do |t|
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..4] == '!rmon'
    info[:what][6..-1].split(',').map(&:strip)

  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    t[:lastused] = Time.now
    
    # aliases
    args = info[:result]
    mondata = Pokedex::POKEMONDATA
    fdata = Pokedex::FORMATSDATA
    
    # this will hold the selected mons
    result = nil
    
    num, tier, arg1 = nil
    
    if (arg1 = args.shift.to_i) > 0
      tier = (args.shift || 'any')
      num = arg1
    else
      tier = (arg1 || 'any')
      num = 1
    end
    
    
    result = num.times.map do
      mon = mondata.keys.sample
      tier == 'any' || (fdata[mon] && fdata[mon]['tier'].downcase == tier.downcase) || retry
      
      mondata[mon]['name']
    end
    
    info[:respond].call("(#{info[:who]}) #{result.join(', ')} (tier=#{tier.upcase})")
  end
end
