require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 

class CLI

    @@prompt = TTY::Prompt.new
    @@artii = Artii::Base.new :font => 'slant'

    def welcome # launches auth flow and prints welcome graphic
        system('clear')
        puts @@artii.asciify("Welcome to")
        puts @@artii.asciify("Spotify ( Lite )!")
        sleep(1)
        puts "\n"
        self.display_menu
    end

    def display_menu # this displays initial log-in menu
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

    def setup_username(username) # username setup for new users
        if User.all.any? { |user| user.username == username }
            puts "Oops! That name is already taken."
            sleep(2)
            puts "Please enter another username:"
            new_username = gets.chomp
            self.setup_username(new_username)
        else
            puts "Perfect. Please create a password:"
            password = gets.chomp
            User.create(username: username, password: password)
            sleep(2)
            puts "You're all set. We are excited to have you!"
            self.launch_dashboard
        end
    end

    def authenticate_username(username) # authenticate reutrning users' usernames
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
    
    def authenticate_password(username, password) # authenticate reutrning users' passwords
        if User.all.any? { |user| user.username == username && user.password = password }
            puts "Welcome back!"
            self.launch_dashboard
        else
            puts "We don't recognize that password. Please re-enter your password:"
            new_password = gets.chomp
            self.authenticate_username(username, new_password)
        end
    end

    def launch_dashboard # launch main menu
        system('clear')
        puts @@artii.asciify("Main Menu")
        choices = { "My Library" => 1, 
                "Create New Playlist" => 2, 
                "Search Playlists" => 3,
                "Exit" => 4
            }
        action = @@prompt.select("Choose an option:", choices)
        case action
        when 1
            puts "Here are your dope playlists"
        when 2
            puts "Let's create playlist"
        when 3
            self.search_playlists
        when 4
            system('clear')
            return 
        end
    end

    ## MY LIBRARY FUNCTIONALITY

    def my_library
    end

    ## CREATE NEW PLAYLIST

    ## PLAYLIST SEARCH FUNCTIONALITY

    def search_playlists # main search playlists menu
        system('clear')
        puts @@artii.asciify("Playlists")
        puts "\n"
        choices = { "Search All" => 1, 
                "Search By Genre" => 2, 
                "Search by Name" => 3,
                "Main Menu" => 4
            }
        action = @@prompt.select("Choose an option:", choices)
        case action
        when 1
            self.search_all_playlists
        when 2
            self.search_by_genre
        when 3
            self.search_by_name
        when 4
            self.launch_dashboard 
        end
    end
    
    def search_all_playlists # allows users to select from all playlists 
        counter = 1
        choices = {}
        Playlist.all.select do |playlist|
            choices[playlist.name] = counter
            counter += 1
        end
        action = @@prompt.select("Choose a playlist:", choices)
        case action
        when action
            puts "Good picks" # open playlist based on actions
        end
    end

    def search_by_genre # see list of all genres; see list of all playlists in selected genre

        # initialize hashes and counters
        first_counter = 1
        second_counter = 1
        genre_choices = {}
        playlist_choices = {} 

        # select genre flow
        genres = Playlist.all_genres
        genres.select do |genre|
            genre_choices[genre] = first_counter
            first_counter += 1
        end
        action_1 = @@prompt.select("Choose a genre:", genre_choices)

        # based on genre, display playlists
        playlists  = Playlist.find_by_genre(genre_choices.key(action_1))
        playlists.select do |playlist|
            playlist_choices[playlist.name] = second_counter
            second_counter += 1
        end
        action_2 = @@prompt.select("Choose a playlist:", playlist_choices)

        # based on selected playlist, output songs
        selected_playlist_name = playlist_choices.key(action_2)
        selected_playlist = Playlist.all.find{|playlist| playlist.name == selected_playlist_name}
        case action_2
        when action_2
            puts selected_playlist.tracks
            # add functionality to add to my playlists
        end

        # choose one and output the associated tracks
        action = @@prompt.select("Choose a playlist:", choices)
        playlist = Playlist.find_by_name(choices.key(action)).first
        puts playlist.tracks

        # option to add to my playlists or go to playlists menu
        playlist_options
    end

    def playlist_options
        choices = {"Yes" => 1, "No" => 2}
        action = @@prompt.select("Add this playlist to your playlists?", choices)
        case action
        when 1
            # add to my playlists
            puts "Successfully added to your playlists"
            sleep(2)
            self.search_playlists
        when 2
            self.search_playlists
        end
    end

    def add_to_my_playlists
    end

end