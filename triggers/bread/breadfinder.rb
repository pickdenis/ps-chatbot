


require 'open-uri'

module BreadFinder
  
  CATALOG_URI = "http://a.4cdn.org/vp/catalog.json"
  
  def self.get_bread &callback
    
    catalog = ''
    
    EventMachine::HttpRequest.new(CATALOG_URI).get.callback do |http|
      error = false
      begin
        catalog = JSON.parse(http.response)
      rescue JSON::ParserError => e
        puts "Could not parse response, possibly because of a 403."
        error = true
      end
      
      if !error
        current_candidate = {no: 0, lr_time: 0}
      
        catalog.each do |page|
          page["threads"].each do |thread|
            if (thread["sub"] =~ /showderp/i ||
              thread["name"] =~ /showderp/i ||
              thread["com"] =~ /showderp/i) &&
              thread["last_replies"]
              
              
              reply_time = thread["last_replies"].max { |reply| reply["time"] }["time"]
              
              if reply_time > current_candidate[:lr_time]
                current_candidate[:no], current_candidate[:lr_time] = thread["no"], reply_time
              end
            end
          end
        end
      else
        current_candidate = {no: "try again in a few seconds", lr_time: 420}
      end
      
      
      callback.call(current_candidate)
    end
    
    
    
  end
end
