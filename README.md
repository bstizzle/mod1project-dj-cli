# DJ-CLI app notes/pitch
Description: An app where users can create, edit, share, search, and listen to playlists of tracks either created generatively or with specific additions

Potentially utilize Billboard Charts API and/or Spotify API

# Models, Attributes, and Associations
User: username
Playlist: user_id
Track: (all the built in info from Spotify)
Review: user_id, playlist_id

Playlist belongs_to Dj
Playlist has_many Users
Playlist has_many Reviews
Playlist has_many Tracks
Playlist has_many Artists through Tracks

Track belongs_to Artist
Track has_many Playlists
Track has_many Djs and Users through Playlists

User has_many Playlists
User has_many Reviews
User has_many Djs and Tracks through Playlists
User has_many Artists through Tracks

Review belongs_to User
Review belongs_to Playlist

playlistTrack join table needed? playlist_id, track_id
playlistUser join table needed? playlist_id, user_id

# Relationship Chart
User => playlistUser <= Playlist => playlistTrack <= Track
User => Playlist <= User
User => Review <= Playlist
			 
# User Stories
As a User, I can see all created playlists
As a User, I can select and save playlists to my library listen to
As a User, I can remove playlists from my library

As a User, I can leave/edit/delete reviews on playlists

As a User, I can create and populate playlists
As a User, I can directly input a song into one of my playlists
As a User, I can generate some Tracks for a playlist by various search methods: genre, artist, popularity, etc.
As A User, I can see how many Users are listening to which of my playlists

asd