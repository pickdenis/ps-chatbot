require 'em-http'

module FCGetter
  URL = "https://docs.google.com/spreadsheet/pub?key=0Apfr8v-a4nORdHVkcjJUTjJrd3hXV1N2T0dIbktuVVE&output=csv"
  
  def self.load_values
    
    @@fcs = {}
    
    EM::HttpRequest.new(URL).get.callback { |http|
      http.response.each_line do |line|
        vals = line.split(',')
        
        name, _, fc = vals
        
        @@fcs[CBUtils.condense_name(name)] = fc
        
      end
    }
    
  end
  
  def self.get_fc name
    @@fcs[CBUtils.condense_name(name)]
  end
end

Trigger.new do |t|

  t[:id] = 'fc'
  
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds

  t.match { |info|
    info[:what][0..2].downcase == '!fc' && info[:what][3..-1].strip
  }
  
  FCGetter.load_values
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now
    
    userfound = false
    
    info[:result] == '' and info[:result] = nil
    who = CBUtils.condense_name(info[:result] || info[:who]) # if no arg specified, then we'll just use whoever asked
    
    fc = FCGetter.get_fc(who)
    
    info[:respond].call(fc ? "#{who}'s FC: #{fc}" : "no FC for #{who}")
    
    FCGetter.load_values

  end
end
