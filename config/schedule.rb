set :chronic_options, hours24: true
env :PATH, ENV['PATH']

here = Dir.pwd

every 1.day, at: '14:00' do
  command "cd #{here} && ruby #{here}/remind.rb"
end
