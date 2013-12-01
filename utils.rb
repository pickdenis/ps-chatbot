module CBUtils
  def condense_name name
    name.downcase.gsub(/[^\w\d]/, '')
  end
end