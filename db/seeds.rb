require 'pry'
require 'rspotify'

User.destroy_all
Playlist.destroy_all
PlaylistUser.destroy_all
PlaylistTrack.destroy_all

ben = User.create(username: 'ben', password: 'ben')
brendan = User.create(username: 'brendan', password: 'brendan')
mf_cloom = User.create(username: 'MF CLI', password: '123')

p1 = Playlist.create(user_id: mf_cloom.id, name: "Hip Hop Classics", genre: "hip hop")
p2 = Playlist.create(user_id: mf_cloom.id, name: "Pop Disco Funk", genre: "Pop")
p3 = Playlist.create(user_id: mf_cloom.id, name: "Homecoming 2020", genre: "EDM")
p4 = Playlist.create(user_id: ben.id, name: "Morning Workout", genre: "Heavy Metal")
p5 = Playlist.create(user_id: brendan.id, name: "Just Broke Up With My GF", genre: "Emo")
p6 = Playlist.create(user_id: ben.id, name: "Bebop", genre: "Jazz")

superstition = RSpotify::Track.search('Superstition', limit: 1, market: 'US').first
idiot = RSpotify::Track.search('American Idiot', limit: 1, market: 'US').first
glass = RSpotify::Track.search('Glass Island', limit: 1, market: 'US').first
anthropology = RSpotify::Track.search('Anthropology', limit: 1, market: 'US').first
toxic = RSpotify::Track.search('Toxic', limit: 1, market: 'US').first
christmas = RSpotify::Track.search('Christmas', limit: 1, market: 'US').first
lazyeye = RSpotify::Track.search('lazy eye', limit: 1, market: 'US').first
blue = RSpotify::Track.search('blue', limit: 1, market: 'US').first
rockyou = RSpotify::Track.search('rock you', limit: 1, market: 'US').first
elmo = RSpotify::Track.search('elmo', limit: 1, market: 'US').first
kidsbop = RSpotify::Track.search('kids bop', limit: 1, market: 'US').first
iagainsti = RSpotify::Track.search('I Against I', limit: 1, market: 'US').first
thirtythirty = RSpotify::Track.search('3030', limit: 1, market: 'US').first
cellz = RSpotify::Track.search('cellz', limit: 1, market: 'US').first
hello = RSpotify::Track.search('Hello', limit: 1, market: 'US').first
panda = RSpotify::Track.search('panda', limit: 1, market: 'US').first
drop_it = RSpotify::Track.search("drop it like it's hot", limit: 1, market: 'US').first
ya_neck = RSpotify::Track.search("Break Ya Neck", limit: 1, market: 'US').first
crossroads = RSpotify::Track.search("Tha Crossroads", limit: 1, market: 'US').first

#hip hop classics playlist
PlaylistTrack.create(playlist_id: p1.id, track_id: cellz.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: thirtythirty.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: panda.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: iagainsti.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: drop_it.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: ya_neck.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: crossroads.id)

# Broke Up with My GF Playlist
PlaylistTrack.create(playlist_id: p5.id, track_id: toxic.id)
PlaylistTrack.create(playlist_id: p5.id, track_id: christmas.id)
PlaylistTrack.create(playlist_id: p5.id, track_id: lazyeye.id)
PlaylistTrack.create(playlist_id: p5.id, track_id: kidsbop.id)

# Morning Workout Playlist
PlaylistTrack.create(playlist_id: p4.id, track_id: toxic.id)
PlaylistTrack.create(playlist_id: p4.id, track_id: christmas.id)
PlaylistTrack.create(playlist_id: p4.id, track_id: lazyeye.id)
PlaylistTrack.create(playlist_id: p4.id, track_id: kidsbop.id)

# Ben's Library
PlaylistUser.create(playlist_id: p1.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p2.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p3.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p5.id, user_id: ben.id)

# Brendan's Library
PlaylistUser.create(playlist_id: p5.id, user_id: brendan.id)
PlaylistUser.create(playlist_id: p1.id, user_id: brendan.id)
PlaylistUser.create(playlist_id: p4.id, user_id: brendan.id)
