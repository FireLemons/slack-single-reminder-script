require 'json'
require 'net/http'
require 'uri'

DELETE_MESSAGE_URI = URI('https://slack.com/api/chat.delete')
SEND_MESSAGE_URI = URI('https://slack.com/api/chat.postMessage')

if File.file?('../config.json')
  config = JSON.parse(File.read('../config.json'))
else
  puts 'ERROR: Missing ../config.json'
  exit 1
end

# Delete the previous message if a previous message id was found
if File.file?('previous_message_id.txt')
  previous_message_id = File.read('previous_message_id.txt')

  delete_message_request = Net::HTTP::Post.new(DELETE_MESSAGE_URI, {
    'Authorization': "Bearer #{config["token"]}",
    'Content-Type': 'application/json'
  })
  delete_message_request.set_form_data({
    'channel': config['channel'],
    'ts': previous_message_id
  })
  delete_message_result = Net::HTTP.start(DELETE_MESSAGE_URI.hostname, DELETE_MESSAGE_URI.port, :use_ssl => true) do |http|
    http.request(delete_message_request)
  end
end

# Send reminder
send_message_request = Net::HTTP::Post.new(SEND_MESSAGE_URI, {
  'Authorization': "Bearer #{config["token"]}",
  'Content-Type': 'application/json'
})
send_message_request.set_form_data({
  'channel': config['channel'],
  'text': config['text']
})
send_message_result = Net::HTTP.start(SEND_MESSAGE_URI.hostname, SEND_MESSAGE_URI.port, :use_ssl => true) do |http|
  http.request(send_message_request)
end

File.write('previous_message_id.txt', JSON.parse(send_message_result.body)['ts'])
