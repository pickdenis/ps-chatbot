# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


require_relative 'breadfinder.rb'

require 'open-uri'

module Battles
  def self.get_battles &callback
    BreadFinder.get_bread do |bread|
      if bread[:no] == 0 
        callback.call([])
        next
      end
      
      battles = []
      thread = nil
      
      EventMachine::HttpRequest.new("http://a.4cdn.org/vp/res/#{bread[:no]}.json").get.callback do |http|
        thread = JSON.parse(http.response)
        
        thread["posts"].each do |post|
          if post["com"] && post["com"].gsub('<wbr>', '') =~ %r{(https?\://play\.pokemonshowdown\.com/battle-(?:ou|oucurrent|oususpecttest|ubers|smogondoublessuspecttest)+-\d+)}
            battles << [$1, post["time"]]
          end
        end
        
        callback.call(battles)
      end
      
      
      
    end
  end
end
