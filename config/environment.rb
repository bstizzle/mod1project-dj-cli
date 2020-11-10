require 'bundler/setup'
Bundler.require

RSpotify::authenticate("a1c02f8e677c46b5b12b8061b4017657", "c15f867c496d49d586e46af820375cca")

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "db/development.sqlite3"
)

# ActiveRecord::Base.logger = Logger.new(STDOUT)
# Comment out line above and uncomment out line below to remove logger when presenting
ActiveRecord::Base.logger =  nil

require_all 'lib'
