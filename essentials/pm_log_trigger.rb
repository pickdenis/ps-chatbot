require 'logger'

Trigger.new do |t|
  t.match { |info|
    info[:where] == 'pm'
  }
  
  logger = Logger.new("./essentials/#{$login[:name]}_pm.log", 'daily')
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime}: #{msg}\n"
  end
  
  t.act do |info|
    logger.info("#{info[:who]} -> #{info[:to]}: #{info[:what]}")
  end
end