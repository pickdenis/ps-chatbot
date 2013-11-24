ChatHandler::TRIGGERS << Trigger.new do |t|
  t.match { |info|
    info[:who] == 'pick' && # initial guard
    info[:what][0..3] == 'fsym' &&
    info[:what][5..-1]
  }
  
  t.act do |info|
    FSymbols.convert(info[:result]).each do |line|
      info[:respond].call(line)
    end
  end
end