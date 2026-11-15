require "net/http"
require "json"

namespace :gold do
  desc "Fetch XAU/USD price and send email notification"
  task notify: :environment do
    uri = URI("https://api.gold-api.com/price/XAU/USD")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      GoldPriceMailer.price_alert(data).deliver_now
      puts "[#{Time.current}] Sent XAU/USD price ($#{data['price']}) to bibochip11@gmail.com"
    else
      Rails.logger.error "Failed to fetch gold price: #{response.code} #{response.message}"
    end
  end
end
