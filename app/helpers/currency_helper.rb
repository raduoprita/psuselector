module CurrencyHelper
  def to_euro(number)
    if number
      "#{number} €"
    else
      ''
    end
  end
end
