# DJ-CLI app notes/pitch
Description: An app where users can create, edit, share, search, and listen to playlists of songs either created generatively or with specific additions

potentially utilize Billboard Charts API and/or Spotify API (spotify API might be able to do all this already, not sure, so maybe don't use it)
(if it is too robust, could deliberately not use most functions of the Spotify API and only use it for its search engine?)
or other music listing/playing API

# Models, Attributes, and Associations
Listener: username
Dj: username
Playlist: dj_id
Song: name, artist_id
Artist: name

Dj has_many Playlists
Dj has_many Listeners and Songs through Playlists
Dj has_many Artists through Songs

Playlist belongs_to Dj
Playlist has_many Listeners
Playlist has_many Songs
Playlist has_many Artists through Songs

Song belongs_to Artist
Song has_many Playlists
Song has_many Djs and Listeners through Playlists

Artist has_many Songs
Artist has_many Playlists through Songs
Artist has many Djs and Listeners through Playlists

Listener has_many Playlists
Listener has_many Djs and Songs through Playlists
Listener has_many Artists through Songs

playlistSong join table needed? playlist_id, song_id
playlistListener join table needed? playlist_id, listener_id

Djs are also Listeners
Listeners are not necessarily Djs
TBD: Listeners can either become Djs by creating their first playlist, or the Djs could be treated as people actually hired by the app company
	If the latter, normal Listeners would then be unable to create their own playlists and the app would be more like a music radio app

# Relationship Chart
Listener => Playlist <= Dj
				^
				|
			  Song
				^
				|
			  Artist

# User Stories
As a listener, I can see all the Djs and their playlists
As a listener, I can select and save playlists to my library listen to
AS a listener, I can remove playlists from my library
As a listener, I can leave/edit/delete reviews on playlists and Djs
# As a listener, I can follow Djs I like and not just their playlists (requieres an additional class?)

As a Dj, I can create and populate playlists, and do all listener actions
As a Dj, I can directly input a song into one of my playlists
As a Dj, I can generate some songs for a playlist by various search methods: genre, artist, popularity, etc.
As A Dj, I can see how many listeners are listening to which of my playlists
	If I'm a popular Dj, maybe also be able to search songs based on what my Listeners are listening to?