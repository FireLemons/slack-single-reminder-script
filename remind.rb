require 'json'
require 'net/http'
require 'uri'

DELETE_MESSAGE_URI = URI('https://slack.com/api/chat.delete')
SEND_MESSAGE_URI = URI('https://slack.com/api/chat.postMessage')

if ARGV.length == 0
  puts "ERROR: message to be sent unspecified"
  exit 1
end

if File.file?('../config.json')
  config = JSON.parse(File.read('../config.json'))
else
  puts 'ERROR: Missing ../config.json'
  exit 1
end

previous_messages = File.file?('./previous_message_ids.json') ? JSON.parse(File.read('./previous_message_ids.json')) : {}

def send_reminder (config, reminder)
  send_message_request = Net::HTTP::Post.new(SEND_MESSAGE_URI, {
    'Authorization': "Bearer #{config["token"]}",
    'Content-Type': 'application/json'
  })
  send_message_request.set_form_data({
    'channel': config['channel'],
    'text': reminder
  })
  send_message_result = Net::HTTP.start(SEND_MESSAGE_URI.hostname, SEND_MESSAGE_URI.port, :use_ssl => true) do |http|
    http.request(send_message_request)
  end

  return JSON.parse(send_message_result.body)['ts']
end

for message in ARGV
  # Delete the previous message if a previous message id was found
  if previous_messages.key?(message)
    previous_message_id = previous_messages[message]

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

  previous_messages[message] = send_reminder(config, config['messages'][message])
end

File.write('./previous_message_ids.json', previous_messages.to_json)
