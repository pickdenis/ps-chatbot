require_relative 'breadfinder.rb'

require 'open-uri'

module Battles
  def self.get_battles &callback
    BreadFinder.get_bread do |bread|
      bread[:no] == 0 and return []
      
      battles = []
      thread = nil
      
      EventMachine::HttpRequest.new("http://a.4cdn.org/vp/res/#{bread[:no]}.json").get.callback do |http|
        thread = JSON.parse(http.response)
        
        thread["posts"].each do |post|
          if post["com"] && post["com"].gsub('<wbr>', '') =~ %r{(https?\://play\.pokemonshowdown\.com/battle-\w+-\d+)}
            battles << [$1, post["time"]]
          end
        end
        
        callback.call(battles)
      end
      
      
      
    end
  end
end
