class GoldPriceMailer < ApplicationMailer
  default from: "bibochip11@gmail.com"

  def price_alert(price_data)
    @price_data = price_data
    mail(
      to: "bibochip11@gmail.com",
      subject: "XAU/USD Gold Price Update: $#{@price_data['price']}"
    )
  end
end
