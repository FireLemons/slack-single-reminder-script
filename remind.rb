require 'json'
require 'net/http'
require 'uri'

token = File.read("../oauth_token.txt")
message = File.read("message.json")

send_message_URI = URI('https://slack.com/api/chat.postMessage')

request_body = {
  "channel": "C01HTBZ264V",
  "text": "test"
} 

send_message_request = Net::HTTP::Post.new(send_message_URI, {
  "Authorization": "Bearer #{token}",
  "Content-Type": "application/json"
})

send_message_request.set_form_data(request_body)
send_message_result = Net::HTTP.start(send_message_URI.hostname, send_message_URI.port, :use_ssl => true) do |http|
  http.request(send_message_request)
end

puts send_message_result.body
