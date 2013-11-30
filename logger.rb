require 'logger'

fmt = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

$logger = Logger.new($>)

$usage_log = Logger.new('logs/usage.log', 'daily')

$logger.formatter = $usage_log.formatter = fmt