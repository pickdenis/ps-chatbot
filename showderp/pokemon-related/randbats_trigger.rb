require './showderp/pokemon-related/pokedata.rb'

Trigger.new do |t|
  t[:id] = "rspd"
  
  t.match { |info|
    info[:what][0..4] == "!rspd" && info[:what].size > 4 &&
    info[:what][6..-1]
  }
  
  t.act do |info|
    rspd = Pokedex::RANDBATS_SPEEDS
    
    result = rspd[info[:result].downcase.gsub(/[^\w]/, '')]
    
    result = if result.nil?
      ""
    else
      "In randbats, #{info[:result].capitalize}'s speed is #{result}."
    end
    
    
    info[:respond].call(result)
  end
end