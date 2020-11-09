require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 

class CLI

    @@prompt = TTY::Prompt.new
    @@artii = Artii::Base.new :font => 'slant'

    def welcome
        system('clear')
        puts @@artii.asciify("Welcome to")
        puts @@artii.asciify("Spotify ( Lite )!")
        sleep(2)
        self.display_menu
    end

    def display_menu
        system('clear')
        choices = { "Log in" => 1, "Sign up" => 2}
        action = @@prompt.select("What would you like to do?", choices)
        case action
        when 1
            puts "Please enter your username:"
            username = gets.chomp
            self.authenticate_username(username)
        when 2
            puts "Please enter a new username:"
            username = gets.chomp
            self.setup_username(username)
        end
    end

    def setup_username(username)
        if User.all.any? { |user| user.username == username }
            puts "Oops! That name is already taken."
            sleep(1)
            puts "Please enter another username:"
            new_username = gets.chomp
            self.setup_username(new_username)
        else
            puts "Perfect. Please create a password:"
            password = gets.chomp
            User.create(username: username, password: password)
            puts "You're all set. We are excited to have you!"
            self.launch_dashboard
        end
    end

    def authenticate_username(username)
        if User.all.any? { |user| user.username == username }
            puts "Please enter your password:"
            password = gets.chomp
            self.authenticate_password(username, password)
        else
            puts "We don't recognize that username. Please re-enter your username:"
            username = gets.chomp
            self.authenticate_username(username)
        end
    end
    
    def authenticate_password(username, password)
        if User.all.any? { |user| user.username == username && user.password = password }
            puts "Welcome back!"
            self.launch_dashboard
        else
            puts "We don't recognize that password. Please re-enter your password:"
            new_password = gets.chomp
            self.authenticate_username(username, new_password)
        end
    end

    def launch_dashboard
        system('clear')
        choices = { "My Playlists" => 1, "Create New Playlist" => 2}
        action = @@prompt.select("Choose an option:", choices)
        case action
        when 1
            puts "Here are your dope playlists"
        when 2
            puts "Let's create playlist"
        end
    end

end