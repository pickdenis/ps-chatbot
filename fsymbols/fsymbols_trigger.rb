ChatHandler::TRIGGERS << Trigger.new do |t|
  t.match { |info|
    info[:what][0..3] == 'fsym' &&
    (info[:who] == 'pick' || info[:who] == 'flippo') && # nexessary guard
    info[:what][5..-1]
  }
  
  t.act do |info|
    FSymbols.convert(info[:result]).each do |line|
      info[:respond].call(line)
    end
  end
end