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

require 'eventmachine'
require 'em-http-request'
require 'fileutils'

module Banlist
  extend self
  
  SS_KEY = '0AvMzk9ZN2tZtdG9jNjFocHNrWVhnajZTa2V1d0dJbmc'
  SS_URL = 'https://docs.google.com/spreadsheet/pub'
  
  FORM_KEY = '1YJQFUBtcrJZKxhe4htXd9_kXPcOlTTdUnFfhtbJjJXY'
  FORM_URL = "https://docs.google.com/forms/d/#{FORM_KEY}/formResponse"
  
  def set_pw pw
    @@pw = pw
  end
  
  def get &callback
    @@banlist = []
    
    EM::HttpRequest.new(SS_URL).get(query: {key: SS_KEY, single: true, gid: 1, output: "csv"}).callback do |http|
      @@banlist.push(*http.response.split("\n"))
      callback.call(@@banlist) if block_given?
    end
  end
  
  def list
    class_variable_defined?("@@banlist") ? @@banlist : []
  end
  
  def action(act, name, &callback)
    # name = CBUtils.condense_name(name)
    if act == "ab"
      @@banlist << name
    elsif act == "uab"
      @@banlist.delete(name)
      
    end
    
    EM::HttpRequest.new(FORM_URL).post(query: {
      "entry.272819384" => "#{act} #{name}",
      "entry.295377180" => @@pw
    }).callback do |http|
      callback.call(http) if block_given?
    end
  end
  
  def ab(name, &callback)
    action("ab", name, &callback)
  end
  
  def uab(name, &callback)
    action("uab", name, &callback)
  end
  
end