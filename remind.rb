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
  $config = JSON.parse(File.read('../config.json'))
else
  puts 'ERROR: Missing ../config.json'
  exit 1
end

previous_message_ids = File.file?('./previous_message_ids.json') ? JSON.parse(File.read('./previous_message_ids.json')) : {}

def delete_reminder (reminder_message_id)
  delete_message_request = Net::HTTP::Post.new(DELETE_MESSAGE_URI, {
    'Authorization': "Bearer #{$config["token"]}",
    'Content-Type': 'application/json'
  })
  delete_message_request.set_form_data({
    'channel': $config['channel'],
    'ts': reminder_message_id
  })
  delete_message_result = Net::HTTP.start(DELETE_MESSAGE_URI.hostname, DELETE_MESSAGE_URI.port, :use_ssl => true) do |http|
    http.request(delete_message_request)
  end
end

def send_reminder (reminder_text)
  send_message_request = Net::HTTP::Post.new(SEND_MESSAGE_URI, {
    'Authorization': "Bearer #{$config["token"]}",
    'Content-Type': 'application/json'
  })
  send_message_request.set_form_data({
    'channel': $config['channel'],
    'text': reminder_text
  })
  send_message_result = Net::HTTP.start(SEND_MESSAGE_URI.hostname, SEND_MESSAGE_URI.port, :use_ssl => true) do |http|
    http.request(send_message_request)
  end

  return JSON.parse(send_message_result.body)['ts']
end

for message in ARGV
  # Delete the previous message if a previous message id was found
  if previous_message_ids.key?(message)
    delete_reminder(previous_message_ids[message])
  end

  previous_message_ids[message] = send_reminder($config['messages'][message])
end

File.write('./previous_message_ids.json', previous_message_ids.to_json)
