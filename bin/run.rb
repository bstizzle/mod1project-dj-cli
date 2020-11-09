require_relative '../config/environment'
require_relative '../lib/app/models/cli.rb'

puts "Welcome to Spotify Lite"
sleep(2)
puts "Do you have an account?"
new_cli = CLI.new
answer = gets.chomp
new_cli.check_answer(answer)





