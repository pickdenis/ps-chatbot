module CBUtils
  def self.condense_name name
    name.downcase.gsub(/[^\w\d]/, '')
  end
  
  def self.login data
    uri = URI.parse("https://play.pokemonshowdown.com/action.php")
        
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data data
  
    JSON.parse(http.request(request).body[1..-1]) # PS returns a ']' before the json
  end
end