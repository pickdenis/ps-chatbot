require 'JSON'


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

Trigger.new do |t|
  t[:id] = "banlist"
  t[:nolog] = true
  
  t.match { |info|
    (info[:where].downcase == 'pm' || info[:where] == 's') &&
    info[:what].downcase == 'banlist'
  }
  
  banlist_path = './showderp/autoban/banlist.txt'
  FileUtils.touch(banlist_path)
  uploader = HasteUploader.new
  
  t.act do |info|
    
    banlist = File.read(banlist_path)
    
    banlist_text = if banlist.strip.empty?
      'nobody'
    else
      banlist
    end
    
    uploader.upload(banlist_text) do |url|
      info[:respond].call(url)
    end
    
  end
end