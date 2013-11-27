require './bread/breadfinder.rb'

require 'open-uri'

module Battles
  def self.get_battles
    bread = BreadFinder.get_bread
    bread[:no] == 0 and return []
    
    battles = []
    thread = nil
    
    open("http://a.4cdn.org/vp/res/16281671.json") do |f|
      thread = JSON.parse(f.read)
    end
    
    
    thread["posts"].each do |post|
      if post["com"] && post["com"].gsub('<wbr>', '') =~ %r{(http\://play\.pokemonshowdown\.com/battle-\w+-\d+)}
        battles << $1
      end
    end
    
    battles
  end
end
