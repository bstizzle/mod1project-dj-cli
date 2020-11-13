# Spotify-Lite App

Our Spotify-Lite app is a command line interface program that leverages the Spotify API to replicate some of the functionality in the proper Spotify application. 

To run the program, type 'ruby bin/run.rb'. After that, just follow the prompts in the CLI to log in or sign up. 

# Models, Attributes, and Associations

User: username, password

Playlist: user_id, name, genre

Track: (all the built in info from Spotify: artist, album, duration, browser url, etc)

PlaylistUser: playlist_id, user_id

PlaylistTrack: playlist_id, track_id

User has_many Playlists

User has_many Tracks through Playlists

Playlist belongs_to User (creator relationship)

Playlist has_many Users (listener relationship)

Playlist has_many Tracks

Track has_many Playlists

Track has_many Users through Playlists

# Relationship Chart

User => PlaylistUser <= Playlist => PlaylistTrack <= Track

User => Playlist (user that created the playlist has a different association to it than users who listen to it)

User => Playlist <= User (users know other users through shared playlists)
#self referentials?
			 
# User Stories

As a User, I can search through all created Playlists 

As a User, I can select and save Playlists to my library listen to 

As a User, I can remove Playlists from my library 

As a User, I can create and populate Playlists

As a User, I can directly input a song into one of my Playlists

As a User, I can generate some Tracks for a Playlist by various search methods: genre, artist, popularity, etc.

As A User, I can see how many Users are listening to which of my Playlists