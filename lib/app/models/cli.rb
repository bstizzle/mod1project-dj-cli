require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 

class CLI 

    @@prompt = TTY::Prompt.new
    @@artii = Artii::Base.new :font => 'slant'
    @@current_user = ''

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
            @@current_user = User.create(username: username, password: password)
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
            @@current_user = User.current_user(username)
            self.launch_dashboard
        else
            puts "We don't recognize that password. Please re-enter your password:"
            new_password = gets.chomp
            self.authenticate_password(username, new_password)
        end
    end

    def launch_dashboard # launch main menu
        system('clear')
        puts @@artii.asciify("Main Menu")
        choices = { "My Library" => 1, 
                "My Created Playlists" => 2, 
                "Search Playlists" => 3,
                "Exit" => 4
            }
        action = @@prompt.select("Choose an option:", choices)
        case action
        when 1
            self.my_library
        when 2
            self.my_creations
        when 3
            self.search_playlists
        when 4
            system('clear')
            return 
        end
    end

    ## MY LIBRARY FUNCTIONALITY

    def my_library
        # initiate choices based on my library
        choices = {}
        counter = 1
        system('clear')
        puts @@artii.asciify("My Library")
        puts "\n"
        @@current_user.library.each do |playlist|
            choices[playlist.name] = counter
            counter += 1
        end
        action = @@prompt.select("Choose a playlist:", choices)

        # select a playlist and output tracks
        playlist = Playlist.find_by_name(choices.key(action)).first
        system('clear')
        puts @@artii.asciify("My Library")
        puts "\n"
        puts "The tracks in #{playlist.name} include:"
        puts playlist.track_names

        # subsequent options: play, add, back
        puts "\n"
        option_choices = { "Play" => 1, "Remove" => 2, "Main Menu" => 3}
        option_choice = @@prompt.select("Choose an option:", option_choices)
        case option_choice
        when 1
            puts playlist.listen_to_tracks
            self.launch_dashboard
        when 2
            @@current_user.remove_playlist(playlist)
            self.launch_dashboard
        when 3
            self.launch_dashboard
        end
    end

    ## CREATED PLAYLIST FUNCTIONALITY

    def my_creations
        choices = {}
        counter = 1
        system('clear')
        puts @@artii.asciify("My Created Playlists")
        puts "\n"
        action_choices = { "Create New" => 1, "Edit Existing" => 2, "Delete" => 3}
        option = @@prompt.select("Choose an option:", action_choices)
        case option
        when 1
            # do something
            puts "Please enter a name for your new playlist:"
            name = gets.chomp
            puts "Enter a genre:"
            genre = gets.chomp
            Playlist.create(user_id: @@current_user.id, name: name, genre: genre)
            puts "Created #{name} playlist."
            sleep(2)
            self.my_creations
        when 2
            @@current_user.playlists.each do |playlist|
                choices[playlist.name] = counter
                counter += 1
            end
            action = @@prompt.select("Choose a playlist:", choices)
        when 3
            @@current_user.playlists.each do |playlist|
                choices[playlist.name] = counter
                counter += 1
            end
            action = @@prompt.select("Choose a playlist:", choices)
        end
    end

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
        playlist = Playlist.find_by_name(choices.key(action)).first
        self.playlist_options(playlist)
        #end
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
       
        # add functionality to add to my playlists            
        self.playlist_options(selected_playlist)
    end

    def search_by_name
        choices = {}
        counter = 1
        puts "Please enter a playlist name:"
        name = gets.chomp

        # collect playlist candidates
        Playlist.find_by_name(name).select do |playlist|
            choices[playlist.name] = counter
            counter += 1
        end

        # choose one and output the associated tracks
        action = @@prompt.select("Choose a playlist:", choices)
        playlist = Playlist.find_by_name(choices.key(action)).first

        # option to add to my playlists or go to playlists menu
        self.playlist_options(playlist)
    end

    def playlist_options(playlist)
        self.track_list(playlist)
        puts "\n"
        choices = {"Yes" => 1, "No" => 2}
        action = @@prompt.select("Add this playlist to your playlists?", choices)
        case action
        when 1
            # add to my playlists
            if @@current_user.has_playlist?(playlist)
                puts "Already in your library silly!"
            else
                @@current_user.add_playlist(playlist)
                puts "Successfully added to your playlists"
            end
            sleep(2)
            self.search_playlists
        when 2
            self.search_playlists
        end
    end

    def track_list(playlist) #formatting for UI niceness
        system('clear')
        puts @@artii.asciify("Playlists")
        puts "\n"
        puts "The tracks in #{playlist.name} include:"
        puts playlist.track_names #uses Playlist#track_names
    end
end