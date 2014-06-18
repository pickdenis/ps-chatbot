Trigger.new do |t|
  t[:id] = 'aboutmsg'
  
  
  t.match { |info|
    info[:where] == 'pm' && info[:what] == 'about'
  }
  
  t.act do |info|
    info[:respond].call(ch.config['aboutmsg'] || 'To set an about message, add a key \'aboutmsg\' in this bot\'s config')
  end
end