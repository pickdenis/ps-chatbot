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

require 'json'


module CBUtils
  def self.condense_name name
    name.downcase.gsub(/[^A-Za-z0-9]/, '')
  end
  
  def self.login name, pass, &callback
    EM::HttpRequest.new("https://play.pokemonshowdown.com/action.php").post(body: {
      'act' => 'login',
      'name' => name,
      'pass' => pass,
      'challengekeyid' => $data[:challengekeyid].to_i,
      'challenge' => $data[:challenge]} ).callback { |http| 
      
      callback.call(JSON.parse(http.response[1..-1])["assertion"]) # PS returns a ']' before the json
    }
  
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
