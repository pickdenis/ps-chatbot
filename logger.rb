require 'logger'

fmt = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

$logger = Logger.new($>)
$logger.formatter = fmt

$usage_log = Logger.new('logs/usage.log', 'daily')
