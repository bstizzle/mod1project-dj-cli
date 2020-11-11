require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 

class CLI 

    @@prompt = TTY::Prompt.new(active_color: :bright_green)
    @@artii = Artii::Base.new :font => 'standard'
    @@current_user = ''
    @@pastel = Pastel.new 

    def welcome # launches auth flow and prints welcome graphic
        system('clear')
        puts @@pastel.green(@@artii.asciify("Welcome to"))
        puts @@pastel.green(@@artii.asciify("Spotify ( Lite )!"))
        puts "\n"
        self.display_menu
    end

    def display_menu # this displays initial log-in menu
        choices = { "Log in" => 1, "Sign up" => 2, "Exit" => 3}
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
        when 3
            return
        end
    end

    ## Authentication flow

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

    ## Main menu

    def launch_dashboard # launch main menu
        system('clear')
        puts @@pastel.green(@@artii.asciify("Main Menu"))
        choices = { "📚 My Library" => 1, 
                "🎶 My Created Playlists" => 2, 
                "🔍 Search Playlists" => 3,
                "👋 Exit" => 4
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

    ## My Library screen

    def my_library
        # initiate choices based on my library
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Library"))
        puts "\n"
        if @@current_user.library.size == 0
            ## add loading spinner here
            puts "You don't have any favorite playlists yet!"
            puts "Try adding some under Search Playlists"
            sleep(3)
            self.launch_dashboard
        else
            choices = {}
            counter = 1
            @@current_user.library.each do |playlist|
                choices[playlist.name] = counter
                counter += 1
            end
            action = @@prompt.select("Choose a playlist:", choices)

            # select a playlist and output tracks
            playlist = Playlist.find_by_name(choices.key(action)).first
            system('clear')
            puts @@pastel.green(@@artii.asciify("My Library"))
            self.track_list(playlist)

            # subsequent options: play, add, back
            puts "\n"
            option_choices = { "🎹 Play" => 1, "❌ Remove" => 2, "🏠 Main Menu" => 3}
            option_choice = @@prompt.select("Choose an option:", option_choices)
            case option_choice
            when 1
                puts playlist.listen_to_tracks
                puts "\n"
                back = { "Back" => 1}
                go_back = @@prompt.select("Go back to the main menu:", back)
                case go_back
                when 1
                    self.launch_dashboard
                end
            when 2
                @@current_user.remove_playlist(playlist)
                self.my_library
            when 3
                self.launch_dashboard
            end
        end
    end

    ## CREATED PLAYLIST FUNCTIONALITY

    def my_creations #see options for playlist user has created
        choices = {}
        counter = 1
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Created Playlists"))
        puts "\n"
        action_choices = { "🆕 Create New" => 1, "🎛️ Edit Existing" => 2, "❌ Delete" => 3, "🏠 Main Menu" => 4}
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
            self.my_creations #creates new empty playlist then goes back to the options menu
        when 2
            @@current_user.playlists.each do |playlist|
                choices[playlist.name] = counter
                counter += 1
            end
            action = @@prompt.select("Choose a playlist:", choices)
            playlist = Playlist.find_by_name(choices.key(action)).first
            system('clear')
            puts @@pastel.green(@@artii.asciify("My Created Playlists"))
            puts "\n"
            self.track_list(playlist)
            puts "\n"
            options = { "➕ Add" => 1, "❌ Remove" => 2, "🔙 Back" => 3}
            selection = @@prompt.select("Choose an option:", options)
            case selection #gives choices for what to edit about playlist
            when 1 # add to playlist
                puts "\n"
                puts "Enter the song name you wish to add:"
                song_name = gets.chomp
                playlist.add_track(spotifind(song_name))
                self.my_creations #adds requested track to playlist and goes back to options menu
            when 2 # remove track from playlist
                system('clear')
                puts @@pastel.green(@@artii.asciify("My Created Playlists"))
                puts "Select the track you want to remove:"
                track_hash = {}
                track_counter = 1
                playlist.track_names.map do |track|
                    track_hash[track.split("by:")[0]] = counter
                    counter += 1
                end
                track_action = @@prompt.select("Choose a track to remove:", track_hash)
                track = self.spotifind(track_hash.key(track_action))
                playlist.remove_track(track)
                self.my_creations #removes requested track from playlist and goes back to options menu
            when 3 # go back
                self.my_creations 
            end 
        when 3 #delete entire playlist
            @@current_user.playlists.each do |playlist|
                choices[playlist.name] = counter
                counter += 1
            end
            action = @@prompt.select("Choose a playlist:", choices)
        when 4 #go back to main menu
            self.launch_dashboard
        end
    end

    ## PLAYLIST SEARCH FUNCTIONALITY

    def search_playlists # main search playlists menu
        system('clear')
        puts @@pastel.green(@@artii.asciify("Playlists"))
        puts "\n"
        choices = { "🎼 Search All" => 1, 
                "🎶 Search By Genre" => 2, 
                "🎵 Search by Name" => 3,
                "🏠 Main Menu" => 4
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

    def search_by_name #searches through all playlists by input name
        choices = {}
        counter = 1
        puts "Please enter a playlist name:"
        name = gets.chomp

        # collect playlist candidates
        Playlist.find_by_name(name).select do |playlist|
            choices[playlist.name] = counter
            counter += 1
        end

        if !(Playlist.find_by_name(name).empty?) #if there are playlist with that name
            # choose one and output the associated tracks
            action = @@prompt.select("Choose a playlist:", choices)
            playlist = Playlist.find_by_name(choices.key(action)).first

            # option to add to my playlists or go to playlists menu
            self.playlist_options(playlist)
        else
            puts "Can't find a playlist associated with that name"
            sleep(2)
            system('clear')
            puts @@pastel.green(@@artii.asciify("Playlists"))
            puts "\n"
            self.search_by_name
        end
    end

    def playlist_options(playlist) #after selecting a playlist from a search method, ask to add or not
        system('clear')
        puts @@pastel.green(@@artii.asciify("Playlists"))
        self.track_list(playlist)
        puts "\n"
        choices = {"✅ Yes" => 1, "❌ No" => 2}
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

    #FORMATING HELPER METHODS

    def track_list(playlist) #encapsulated formatting for UI niceness
        puts "\n"
        puts "The tracks in #{playlist.name} include:"
        puts "\n"
        counter = 0
        playlist.tracks.each do |track|
            puts playlist.track_names[counter] #uses Playlist#track_names
            puts playlist.listen_to_tracks[counter]
            puts "\n"
            counter += 1
        end 
    end

    def spotifind(track_name) #encapsulates RSpotify search method
        RSpotify::Track.search(track_name, limit: 1, market: 'US').first
    end
end