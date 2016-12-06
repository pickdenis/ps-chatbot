

require 'json'


module CBUtils
  def self.condense_name name
    name.downcase.gsub(/[^a-z0-9]/, '')
  end
  
  def self.login name, pass, challenge, challengekeyid, &callback
    EM::HttpRequest.new("https://play.pokemonshowdown.com/action.php").post(body: {
      'act' => 'login',
      'name' => name,
      'pass' => pass,
      'challengekeyid' => challengekeyid.to_i,
      'challenge' => challenge} ).callback { |http| 
      
      callback.call(JSON.parse(http.response[1..-1])["assertion"]) # PS returns a ']' before the json
    }
  
  end
  
  def self.command(name, num_args = Numeric)                   
    pattern = /!#{name}\s*((?:[^,]+,?\s*)+)/              
    lambda { |cmd|                                        
      match = cmd.match(pattern)                          
                                                          
      return nil unless match                             
      args = match[1].split(/,\s*/)                       
      return :syntax_error unless num_args === args.size  
      args                                                
    }                                                     
  end                                                     
  
  
  def self.safe_read(file)
    File.read(file, 
      external_encoding: 'iso-8859-1',
      internal_encoding: 'utf-8')
  end

  class HasteUploader # Asynchronous with eventmachine!
    def initialize
      @url = 'http://hastebin.com/documents'
    end
    
    def upload text, &callback
      EM::HttpRequest.new(@url).post(body: text).callback do |http|
        haste_id = JSON.parse(http.response)['key']
        haste_url = "http://hastebin.com/#{haste_id}"
        callback.call(haste_url)
      end
    end
  end

end
