module CBUtils
  def self.condense_name name
    name.downcase.gsub(/[^\w\d]/, '')
  end
end