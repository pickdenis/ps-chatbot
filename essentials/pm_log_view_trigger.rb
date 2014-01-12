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


Trigger.new do |t|
  
  
  
  t[:nolog] = true
  
  t.match { |info|
    access_path = "./#{info[:ch].group}/accesslist.txt"
    FileUtils.touch(access_path)
    t[:who_can_access] ||= File.read(access_path).split("\n")
    
    who = CBUtils.condense_name(info[:who])
    
    (info[:where].downcase == 'pm' || info[:where].downcase == 's') && 
    info[:what].downcase == 'pmlog' && t[:who_can_access].index(who)
  }
  
  pmlog_path = nil
  
  begin
    FileUtils.touch(pmlog_path)
  rescue => e
    puts "#{e}, ignoring"
  end
  
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    
    pmlog_path ||= "./essentials/#{t[:login_name]}_pm.log"
    
    pmlog = File.read(pmlog_path)
    
    uploader.upload(pmlog) do |url|
      info[:respond].call(url)
    end
    
  end
end