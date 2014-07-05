


require_relative 'breadfinder.rb'

require 'open-uri'

module Battles
  BATTLE_REGEX = "(https?\\:\\/\\/play\\.pokemonshowdown\\.com\\/battle-(?:FORMATS)\\-\\d+)"
  
  
  def self.get_battles &callback
    real_regex = Regexp.new(BATTLE_REGEX.gsub("FORMATS", $battle_formats.join('|')))
    
    BreadFinder.get_bread do |bread|
      if bread[:no] == 0 
        callback.call([])
        next
      end
      
      battles = []
      thread = nil
      
      EventMachine::HttpRequest.new("http://a.4cdn.org/vp/res/#{bread[:no]}.json").get.callback do |http|
        if !http.response || http.response.size < 2
          callback.call([])
        end
          
        thread = JSON.parse(http.response)
        
        thread["posts"].each do |post|
          if post["com"] && post["com"].gsub('<wbr>', '') =~ real_regex
            battles << [$1, post["time"]]
          end
        end
        
        callback.call(battles)
      end
      
      
      
    end
  end
end
