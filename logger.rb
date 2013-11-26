require 'logger'

$logger = Logger.new($>)
$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end