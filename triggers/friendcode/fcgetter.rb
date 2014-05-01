module FCGetter
  URL = "https://docs.google.com/spreadsheet/pub?key=0Apfr8v-a4nORdHVkcjJUTjJrd3hXV1N2T0dIbktuVVE&output=csv"
  
  def self.load_values
    
    @@fcs = {}
    
    EM::HttpRequest.new(URL).get.callback { |http|
      http.response.each_line do |line|
        vals = line.split(',')
        
        name, _, fc = vals
        
        @@fcs[CBUtils.condense_name(name)] = {fc: fc, realname: name}
        
      end
    }
    
  end
  
  def self.get_fc name
    @@fcs[CBUtils.condense_name(name)]
  end
end