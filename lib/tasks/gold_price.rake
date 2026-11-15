require "net/http"
require "json"

namespace :gold do
  desc "Fetch XAU/USD price and send ntfy notification"
  task notify: :environment do
    require "net/http"
    require "json"

    # Fetch gold price
    uri = URI("https://api.gold-api.com/price/XAU/USD")

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 10,
      read_timeout: 15
    ) do |http|
      http.get(uri)
    end

    raise "Gold API error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)

    price = data.fetch("price")

    message = <<~MESSAGE
      XAU/USD Gold Price Update

      Price: $#{price} USD
      Symbol: XAU/USD
      Updated at: #{Time.current.strftime("%Y-%m-%d %H:%M:%S %Z")}

      Source: https://api.gold-api.com/price/XAU/USD
    MESSAGE

    # Send notification through ntfy
    ntfy_uri = URI("https://ntfy.sh/priceMailer")

    ntfy_response = Net::HTTP.start(
      ntfy_uri.host,
      ntfy_uri.port,
      use_ssl: true,
      open_timeout: 10,
      read_timeout: 15
    ) do |http|
      request = Net::HTTP::Post.new(ntfy_uri)
      request["Content-Type"] = "text/plain; charset=utf-8"
      request["Title"] = "XAU/USD Gold Price"
      request["Priority"] = "high"
      request.body = message

      http.request(request)
    end

    raise "ntfy error: #{ntfy_response.code}" unless ntfy_response.is_a?(Net::HTTPSuccess)

    puts message
    puts "Notification sent successfully!"
  end
end
