require './showderp/pokemon-related/pokedata.rb'

Trigger.new do |t|
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    (info[:what][0..5] == '!rmon ' && info[:what][6..-1].gsub(/,/, '').split(' ').map(&:strip)) ||
    (info[:what][0..4] == '!rmon' && []) 

  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    t[:lastused] = Time.now
    
    # aliases
    mondata = Pokedex::POKEMONDATA
    fdata = Pokedex::FORMATSDATA
    
    # this will hold the selected mons
    result = []
    
    num, arg1 = nil
    stiers = []
    args = info[:result]
    
    tiers = ['UBER', 'OU', 'UU', 'RU', 'NU', 'LC', 'CAP', 'BL', 'BL2', 'BL3', 'NFE']
    
    if args[0].to_i > 0
      num = args.shift.to_i
    else
      num = 1
    end
    
    args.each_with_index do |arg|
      stiers << (tiers.index(arg) ? arg.upcase : 'ANY')
    end
    
    stiers = ['ANY'] if stiers == []
    
    next if num > 6
    
    num.times do
      mon = mondata.keys.sample
      redo if fdata[mon].nil?
      redo if (montier = fdata[mon]['tier']).nil?
      redo if stiers.all? { |t| tiers.index(t) } && !stiers.index(montier)
      
      result << mondata[mon]['name']
    end
    
    info[:respond].call("(#{info[:who]}) #{result.join(', ')} (tiers #{stiers.join(', ')})")
  end
end
