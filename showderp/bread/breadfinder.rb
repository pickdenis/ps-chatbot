require 'open-uri'

module BreadFinder
  
  CATALOG_URI = "http://a.4cdn.org/vp/catalog.json"
  
  def self.get_bread &callback
    
    catalog = ''
    
    EventMachine::HttpRequest.new(CATALOG_URI).get.callback do |http|
      catalog = JSON.parse(http.response)
      
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
      
      
      callback.call(current_candidate)
    end
    
    
    
  end
end
