class String
  # TODO leads to nicer OO chaining syntax, is it worth it ?
  def nil_or_non_blank_value
    blank? ? nil : self
  end
  def non_blank_or s
    blank? ? s : self
  end
end
