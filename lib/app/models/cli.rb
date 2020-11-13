require 'tty-prompt'
require "pry"
require 'rest-client'  
require 'json' 
require 'tty-spinner'
require 'launchy'

class CLI 

    @@prompt = TTY::Prompt.new(active_color: :bright_green)
    @@artii = Artii::Base.new :font => 'rounded'
    @@current_user = ''
    @@pastel = Pastel.new 
    @@spinner = TTY::Spinner.new("[:spinner] Loading...", format: :pulse_2)
    @@record_spinner = TTY::Spinner.new(":spinner ", format: :spin)

    def welcome # launches auth flow and prints welcome graphic
        system('clear')
        puts @@pastel.green(@@artii.asciify("Welcome to"))
        puts @@pastel.green(@@artii.asciify("Spotify ( Lite )!"))
        puts "\n"
        self.display_menu
    end

    def display_menu # this displays initial log-in menu
        choices = { "Log in" => 1, "Sign up" => 2, "Exit" => 3}
        action = @@prompt.select("\nWhat would you like to do?", choices)
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
            puts "\nWe don't recognize that username."
            puts "\nPlease re-enter your username (type 'exit' to quit or type 'sign up' to create an account):"
            username = gets.chomp
            if username.downcase == 'exit'
                system('clear')
                return
            elsif username.downcase == 'sign up'
                puts "\nPlease enter your desired username:"
                new_username = gets.chomp
                self.setup_username(new_username)
            else
                self.authenticate_username(username)
            end
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
                "💻 Sign Out" => 4,
                "👋 Exit" => 5
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
            self.display_menu
        when 5
            system('clear')
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
            choices = { "Search Playlists" => 1, "Back" => 2}
            action = @@prompt.select("\n", choices)
            case action
            when 1
                self.search_playlists
            when 2
                self.launch_dashboard
            end
        else
            choices = self.create_choices_hash(@@current_user.library)
            choices["🔍 Search Playlists"] = (choices.size + 1)
            action = @@prompt.select("Your playlists:", choices)

            # check if user wants to go back
            if action == choices.size-1
                self.launch_dashboard 
            elsif action == choices.size 
                self.search_playlists
            else
                # select a playlist and output tracks
                playlist = Playlist.find_by_name(choices.key(action)).first
                self.select_library_playlist(playlist)
            end
        end    
    end

    ## my_libray helper methods

    def select_library_playlist(playlist)
        system('clear')
        puts @@pastel.green(@@artii.asciify("#{playlist.name}"))
        puts @@pastel.blue(@@artii.asciify("by: #{playlist.user.username}"))
        self.track_list(playlist)
        # subsequent options: remove & back
        puts "\n"
        option_choices = { "🎶 Play" => 1, "❌ Remove" => 2, "🔙 Back" => 3}
        option_choice = @@prompt.select("Choose an option:", option_choices)
        case option_choice
        when 1
            self.play_playlist(playlist)
            self.select_library_playlist(playlist)
        when 2
            self.remove_playlist_from_library(playlist)
        when 3
            self.my_library
        end
    end

    def remove_playlist_from_library(playlist)
        choices = {"✅ Yes" => 1, "❌ No" => 2}
        action = @@prompt.select("\nAre you sure you want to remove this playlist?", choices)
        case action
        when 1
            @@current_user.remove_playlist(playlist) 
            @@current_user.reload
            self.spin_baby_spin
            puts "\nSuccessfully removed #{playlist.name} from library"
            sleep(2)
            self.my_library 
        when 2
            self.select_library_playlist(playlist)
        end
    end

    ## Created playlist functionality

    def my_creations #see options for playlist user has created
        choices = {}
        counter = 1
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Created Playlists"))
        puts "\n"
        action_choices = { "💿 My Playlists" => 1, "🆕 Create New" => 2, "🏠 Main Menu" => 3}
        #WE WANT create option, go back option, and list of selectable playlists
        option = @@prompt.select("Choose an option:", action_choices)
        case option
        when 1 #see and edit or delete existing playlist
            self.edit_existing_playlist
        when 2 # create new playlist
            self.create_new_playlist
        when 3 #go back to main menu
            self.launch_dashboard
        end
    end

    ## my_creations helper methods

    def create_new_playlist #create new playlist helper method
        puts "\nPlease enter a name for your new playlist (or hit enter to go back):"
        name = gets.chomp
        if name == ""
            self.my_creations
        else
            puts "\nEnter a genre:"
            genre = gets.chomp
            playlist = Playlist.create(user_id: @@current_user.id, name: name, genre: genre)
            @@current_user.reload
            self.spin_baby_spin
            puts "\nCreated #{name} playlist."
            sleep(2)
            self.select_playlist_to_edit(playlist) #creates new empty playlist then goes back to the options menu
        end
    end

    def edit_existing_playlist #edit existing helper method
        system('clear')
        puts @@pastel.green(@@artii.asciify("My Created Playlists"))
        edit_choices = self.create_choices_hash(@@current_user.playlists)
        if edit_choices.size == 1
            self.spin_baby_spin
            puts "\nYou don't have any playlists to edit"
            sleep(1)
            puts "\nTry adding some under Create New"
            sleep(1)
            back_hash = {"🔙 Back" => 1}
            action = @@prompt.select("", back_hash)
            self.my_creations
        else
            edit_action = @@prompt.select("\nChoose a playlist:", edit_choices)
            if edit_action == edit_choices.size
                self.my_creations
            else
                playlist_to_edit = Playlist.find_by_name(edit_choices.key(edit_action)).first 
                self.select_playlist_to_edit(playlist_to_edit)
            end
        end
    end

    def select_playlist_to_edit(playlist)
        system('clear')
        puts @@pastel.green(@@artii.asciify("#{playlist.name}"))
        puts @@pastel.blue(@@artii.asciify("by: #{playlist.user.username}"))
        puts "\n"
        self.track_list(playlist)
        puts "\n"
        edit_options = { "➕ Add Track" => 1, "❌ Remove Track" => 2, "🎶 Play Tracks" => 3, "💥 Delete Playlist" => 4, "🔙 Back" => 5}
        selection = @@prompt.select("Choose an option:", edit_options)
        case selection #gives choices for what to edit about playlist
        when 1 # add to playlist
            self.edit_existing_add_to_playlist(playlist)
        when 2 # remove track from playlist
            self.edit_existing_remove_track(playlist)
        when 3 #play tracks 
            self.play_playlist(playlist)
            self.select_playlist_to_edit(playlist)
        when 4 #delete playlist from db
            self.delete_existing_playlist(playlist)
        when 5 # go back
            self.edit_existing_playlist
        end
    end
    
    def edit_existing_add_to_playlist(playlist) #add track helper method
        puts "\n"
        puts "Enter the song name you wish to add (hit enter to go back):"
        song_name = gets.chomp
        if song_name == ''
            self.select_playlist_to_edit(playlist)
        else
            playlist.add_track(spotify_by_trackname(song_name))
            self.select_playlist_to_edit(playlist)
        end 
    end

    def edit_existing_remove_track(playlist) #remove track helper method
        if !(playlist.tracks.empty?)
            system('clear')
            puts @@pastel.green(@@artii.asciify("My Created Playlists"))
            puts "\nSelect the track you want to remove:"
            track_hash = self.create_choices_hash(playlist.track_names)
            track_action = @@prompt.select("\nChoose a track to remove:", track_hash)
            choices = {"✅ Yes" => 1, "❌ No" => 2}
            action = @@prompt.select("\nAre you sure you want to delete this playlist?", choices)
            case action 
            when 1
                playlist.remove_track(RSpotify::Track.find(playlist.tracks[track_action-1]))
                self.select_playlist_to_edit(playlist) #removes requested track from playlist and goes back to options menu
            when 2 
                self.select_playlist_to_edit(playlist)
            end 
        else
            puts "\nThere are no tracks in that playlist yet"
            self.spin_baby_spin
            self.select_playlist_to_edit(playlist)
        end
    end

    def delete_existing_playlist(playlist) #delete playlist helper method
        choices = {"✅ Yes" => 1, "❌ No" => 2}
        action = @@prompt.select("\nAre you sure you want to delete this playlist?", choices)
        case action
        when 1
            @@current_user.delete_playlist(playlist) 
            @@current_user.reload
            self.spin_baby_spin
            puts "\nSuccessfully deleted #{playlist.name}"
            sleep(2)
            self.my_creations 
        when 2
            self.select_playlist_to_edit(playlist)
        end
    end

    ## Playlist search functionality 

    def search_playlists # main search playlists menu
        system('clear')
        puts @@pastel.green(@@artii.asciify("Search Playlists"))
        puts "\n"
        choices = { "🎼 Search All" => 1, 
                "🎶 Search By Genre" => 2, 
                "🎵 Search by Name" => 3,
                "📚 My Library" => 4,
                "🏠 Main Menu" => 5
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
            self.my_library
        when 5
            self.launch_dashboard 
        end
    end
    
    ## Search playlist helper methods

    def search_all_playlists # allows users to select from all playlists 
        choices = self.create_choices_hash(Playlist.all)
        action = @@prompt.select("Choose a playlist:", choices)
        if action == choices.size
            self.search_playlists
        else
            playlist = Playlist.find_by_name(choices.key(action)).first
            self.playlist_options(playlist)
        end
    end

    def search_by_genre # see list of all genres; see list of all playlists in selected genre
        genre_choices = self.create_choices_hash(Playlist.all_genres)
        action_1 = @@prompt.select("\nChoose a genre:", genre_choices)

        if action_1 == genre_choices.size 
            self.search_playlists
        else
            playlist_choices = self.create_choices_hash(Playlist.find_by_genre(genre_choices.key(action_1)))
            action_2 = @@prompt.select("\nChoose a playlist:", playlist_choices)

            if action_2 == playlist_choices.size 
                self.search_playlists
            else
                # based on selected playlist, output songs
                selected_playlist_name = playlist_choices.key(action_2)
                selected_playlist = Playlist.all.find{|playlist| playlist.name == selected_playlist_name}
            
                # add functionality to add to my playlists            
                self.playlist_options(selected_playlist)
            end
        end
    end

    def search_by_name #searches through all playlists by input name
        puts "\nPlease enter a playlist name (hit enter to go back):"
        name = gets.chomp
        if name == ''
            self.search_playlists
        else 
            choices = self.create_choices_hash(Playlist.find_by_name(name))

            if !(Playlist.find_by_name(name).empty?) #if there are playlist with that name
                # choose one and output the associated tracks
                action = @@prompt.select("Choose a playlist:", choices)
                if action == choices.size
                    self.search_playlists
                else
                    playlist = Playlist.find_by_name(choices.key(action)).first

                    # option to add to my playlists or go to playlists menu
                    self.playlist_options(playlist)
                end
            else
                puts "Can't find a playlist associated with that name"
                sleep(2)
                system('clear')
                puts @@pastel.green(@@artii.asciify("Playlists"))
                puts "\n"
                self.search_by_name
            end
        end
    end

    def playlist_options(playlist) #after selecting a playlist from a search method, ask to add or not
        system('clear')
        puts @@pastel.green(@@artii.asciify("#{playlist.name}"))
        puts @@pastel.blue(@@artii.asciify("by: #{playlist.user.username}"))
        self.track_list(playlist)
        puts "\n"
        choices = {"🎶 Play Tracks" => 1, "✅ Add to Library" => 2, "🔙 Back" => 3}
        action = @@prompt.select("What to do:", choices)
        case action
        when 1
            self.play_playlist(playlist)
            self.playlist_options(playlist)
        when 2
            # add to my playlists
            if @@current_user.has_playlist?(playlist)
                puts "\nLooks like that playlist is already in your library 👌"
            else
                @@current_user.add_playlist(playlist)
                puts "\nSuccessfully added #{playlist.name} to your library"
            end
            sleep(2)
            self.search_playlists
        when 3
            self.search_playlists
        end
    end

    ## Formatting and encapsulation helper methods

    def track_list(playlist) # encapsulated formatting for UI niceness
        puts "\n"
        puts "The tracks in #{playlist.name} include:"
        puts "\n"
        counter = 0
        
        playlist.tracks.each do |track|
            @@record_spinner.auto_spin
            puts playlist.track_names[counter] # uses Playlist#track_names
            puts playlist.listen_to_tracks[counter]
            puts "\n"
            counter += 1
        end
        @@record_spinner.stop('Copy the URLs to play the songs')
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
        artist_options = RSpotify::Artist.search(artist_name, limit: 10, market: 'US')
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
        choices["🔙 Back"] = counter
        choices
    end

    def play_playlist(playlist) #keeps playing playlists until you hit back, then returns you to the playlist options screen you were in before
        system("clear")
        puts @@pastel.green(@@artii.asciify("#{playlist.name}"))
        puts @@pastel.blue(@@artii.asciify("by: #{playlist.user.username}"))
        puts "\n"
        track_name_list = self.create_choices_hash(playlist.track_names)
        track_id_list = self.create_choices_hash(playlist.tracks)
        puts "\n"
        play_action = @@prompt.select("Select a song to play:", track_name_list)
        if play_action == track_name_list.size
            return
        else
            track_url = RSpotify::Track.find(track_id_list.key(play_action)).external_urls["spotify"]
            Launchy.open(track_url)
            self.play_playlist(playlist)       
        end
    end
end