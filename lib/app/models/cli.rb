require 'tty-prompt'
require "pry"
require 'rest-client'  
require 'json' 
require 'tty-spinner'

class CLI 

    @@prompt = TTY::Prompt.new(active_color: :bright_green)
    @@artii = Artii::Base.new :font => 'standard'
    @@current_user = ''
    @@pastel = Pastel.new 
    @@spinner = TTY::Spinner.new("[:spinner] Loading...", format: :pulse_2)

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
            puts "\nPlease enter your username:"
            username = gets.chomp
            self.authenticate_username(username)
        when 2
            puts "\nPlease enter a new username:"
            username = gets.chomp
            self.setup_username(username)
        when 3
            return
        end
    end

    ## Authentication flow

    def setup_username(username) # username setup for new users
        if User.all.any? { |user| user.username == username }
            self.spin_baby_spin
            puts "\nOops! That username is already taken."
            sleep(2)
            puts "\nPlease enter another username:"
            new_username = gets.chomp
            self.setup_username(new_username)
        else
            puts "\nGreat choice 💯" 
            sleep(2)
            puts "\nNow, create a password (the longer, the better 👀):"
            password = gets.chomp
            @@current_user = User.create(username: username, password: password)
            self.spin_baby_spin
            puts "\nYou're all set. Welcome to the Spotify-Lite fam 🎼"
            sleep(2)
            self.launch_dashboard
        end
    end

    def authenticate_username(username) # authenticate returning users' usernames
        if User.all.any? { |user| user.username == username }
            puts "\nPlease enter your password:"
            password = gets.chomp
            self.authenticate_password(username, password)
        else
            puts "\nWe don't recognize that username. Please re-enter your username (or type exit to quit):"
            username = gets.chomp
            if username == 'exit'
                system('clear')
                return
            end
            self.authenticate_username(username)
        end
    end

    def authenticate_password(username, password) # authenticate reutrning users' passwords
        if User.all.any? { |user| user.username == username && user.password == password }
            self.spin_baby_spin
            @@current_user = User.current_user(username)
            self.launch_dashboard
        else
            puts "\nWe don't recognize that password. Please re-enter your password (or type exit to quit):"
            new_password = gets.chomp
            if new_password == 'exit'
                system('clear')
                return
            end
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

    ## My library functionality

    def my_library
        # initiate choices based on my library
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Library"))
        puts "\n"
        if @@current_user.library.size == 0
            ## add loading spinner here
            puts "You don't have any favorite playlists yet!"
            sleep(2)
            puts "\nTry adding some under Search Playlists"
            sleep(2)
            self.launch_dashboard
        else
            choices = self.create_choices_hash(@@current_user.library)
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

    ## Created playlist functionality

    def my_creations #see options for playlist user has created
        choices = {}
        counter = 1
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Created Playlists"))
        puts "\n"
        action_choices = { "🆕 Create New" => 1, "🎛️  Edit Existing" => 2, "❌ Delete" => 3, "🏠 Main Menu" => 4}
        option = @@prompt.select("Choose an option:", action_choices)
        case option
        when 1 # create new playlist
            puts "\nPlease enter a name for your new playlist:"
            name = gets.chomp
            puts "\nEnter a genre:"
            genre = gets.chomp
            Playlist.create(user_id: @@current_user.id, name: name, genre: genre)
            self.spin_baby_spin
            puts "\nCreated #{name} playlist."
            sleep(2)
            self.my_creations #creates new empty playlist then goes back to the options menu
        when 2 # edit existing 
            edit_choices = self.create_choices_hash(@@current_user.playlists)
            if edit_choices.size == 0
                  self.spin_baby_spin
                  puts "\nYou don't have any playlists to edit"
                  sleep(1)
                  puts "\nTry adding some under Create New"
                  sleep(1)
                  self.my_creations 
            end
            edit_action = @@prompt.select("Choose a playlist:", edit_choices)
            playlist_to_edit = Playlist.find_by_name(edit_choices.key(edit_action)).first
            system('clear')
            puts @@pastel.green(@@artii.asciify("My Created Playlists"))
            puts "\n"
            self.track_list(playlist_to_edit)
            puts "\n"
            edit_options = { "➕ Add" => 1, "❌ Remove" => 2, "🔙 Back" => 3}
            selection = @@prompt.select("Choose an option:", edit_options)
            case selection #gives choices for what to edit about playlist
            when 1 # add to playlist
                puts "\n"
                puts "Enter the song name you wish to add:"
                song_name = gets.chomp
                playlist_to_edit.add_track(spotify_by_trackname(song_name))
                self.my_creations #adds requested track to playlist and goes back to options menu
            when 2 # remove track from playlist
                if !(playlist_to_edit.tracks.empty?)
                    system('clear')
                    puts @@pastel.green(@@artii.asciify("My Created Playlists"))
                    puts "Select the track you want to remove:"
                    track_hash = self.create_choices_hash(playlist_to_edit.track_names)
                    track_action = @@prompt.select("Choose a track to remove:", track_hash)
                    playlist_to_edit.remove_track(RSpotify::Track.find(playlist_to_edit.tracks[track_action-1]))
                    self.my_creations #removes requested track from playlist and goes back to options menu
                else
                    puts "\nThere are no tracks in that playlist"
                    self.spin_baby_spin
                    self.my_creations
                end
            when 3 # go back
                self.my_creations 
            end 
        when 3 # delete entire playlist
            if @@current_user.playlists.size == 0
                puts "\nLooks like you don't have any playlists to delete 🤦"
                sleep(2)
                self.my_creations 
            else
                ###PROBLEM FOR INSTRUCTORS HEREEEE
                deletion_choies = self.create_choices_hash(@@current_user.playlists)
                binding.pry
                deletion_choice = @@prompt.select("Choose a playlist to delete:", deletion_choices)
                playlist_obj = Playlist.find_by_name(deletion_choices.key(deletion_choice)).first
                #@@current_user.remove_playlist(playlist_obj)
                @@current_user.delete_playlist(playlist_obj) # THIS IS THE PROBLEM
                self.spin_baby_spin
                puts "\nSuccessfully removed #{playlist_obj.name}"
                sleep(2)
                self.my_creations 
                ###PROBLEM ABOVE!!!!!!!!!!!!!!!
            end
        when 4 #go back to main menu
            self.launch_dashboard
        end
    end

    ## Playlist search functionality 

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
        choices = self.create_choices_hash(Playlist.all)
        action = @@prompt.select("Choose a playlist:", choices)
        playlist = Playlist.find_by_name(choices.key(action)).first
        self.playlist_options(playlist)
        #end
    end

    def search_by_genre # see list of all genres; see list of all playlists in selected genre
        genre_choices = self.create_choices_hash(Playlist.all_genres)
        action_1 = @@prompt.select("Choose a genre:", genre_choices)

        playlist_choices = self.create_choices_hash(Playlist.find_by_genre(genre_choices.key(action_1)))
        action_2 = @@prompt.select("Choose a playlist:", playlist_choices)

        # based on selected playlist, output songs
        selected_playlist_name = playlist_choices.key(action_2)
        selected_playlist = Playlist.all.find{|playlist| playlist.name == selected_playlist_name}
       
        # add functionality to add to my playlists            
        self.playlist_options(selected_playlist)
    end

    def search_by_name #searches through all playlists by input name
        puts "\nPlease enter a playlist name:"
        name = gets.chomp
        
        choices = self.create_choices_hash(Playlist.find_by_name(name))

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
                puts "\nLooks like that playlist is already in your library 👌"
            else
                @@current_user.add_playlist(playlist)
                puts "\nSuccessfully added #{playlist.name} to your library"
            end
            sleep(2)
            self.search_playlists
        when 2
            self.search_playlists
        end
    end

    ## Formatting helper methods

    def track_list(playlist) # encapsulated formatting for UI niceness
        puts "\n"
        puts "The tracks in #{playlist.name} include:"
        puts "\n"
        counter = 0
        playlist.tracks.each do |track|
            puts playlist.track_names[counter] # uses Playlist#track_names
            puts playlist.listen_to_tracks[counter]
            puts "\n"
            counter += 1
        end 
    end

    def spotify_by_trackname(track_name) #encapsulates RSpotify search method for tracks
        track_options = RSpotify::Track.search(track_name, limit: 10, market: 'US')
        counter = 1
        choices = {}
        track_options.select do |track|
            choices["#{track.name} by: #{@@pastel.green(track.artists.first.name)}"] = counter
            counter += 1
        end
        action = @@prompt.select("Choose a track:", choices) #choose which song you want from a few search results
        track = track_options[action-1]
    end

    def spotify_by_artistname(artist_name) #encapsulates RSpotify search method for artists
        artist_options = RSpotify::Artist.search('Arctic', limit: 10, market: 'US')
        counter = 1
        choices = {}
        artist_options.select do |artist|
            choices[artist] = counter
            counter += 1
        end
        action = @@prompt.select("Choose a artist:", choices) #choose which artist you want from a few search results
        artist = artist_options[action-1]
    end

    def spin_baby_spin # initializes and closes spinner object
        puts "\n"
        @@spinner.auto_spin 
        sleep(2)
        @@spinner.stop
    end

    def create_choices_hash(resource) #helper method for filling our tty-prompy choice hashes, takes @@current_user.user_method as input for resource
        counter = 1
        choices = {}
        resource.each do |item|
            if item.is_a? String
                choices[item] = counter
            else
                choices[item.name] = counter
            end 
            counter += 1
        end
        choices
    end

end