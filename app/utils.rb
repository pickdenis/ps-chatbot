module CBUtils
  def self.condense_name name
    name.downcase.gsub(/[^A-Za-z0-9]/, '')
  end
  
  def self.login name, pass
    uri = URI.parse("https://play.pokemonshowdown.com/action.php")
        
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data 'act' => 'login',
      'name' => name,
      'pass' => pass,
      'challengekeyid' => $data[:challengekeyid].to_i,
      'challenge' => $data[:challenge]
  
    JSON.parse(http.request(request).body[1..-1]) # PS returns a ']' before the json
  end
end