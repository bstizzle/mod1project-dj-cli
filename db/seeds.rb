require 'pry'
require 'rspotify'

User.destroy_all
Playlist.destroy_all
PlaylistUser.destroy_all
PlaylistTrack.destroy_all

#binding.pry

ben = User.create(username: 'ben', password: 'ben')
brendan = User.create(username: 'brendan', password: 'brendan')
mf_cli = User.create(username: 'MF CLI', password: '123')

p1 = Playlist.create(user_id: mf_cli.id, name: "Easy Jazz", genre: "Jazz")
p2 = Playlist.create(user_id: mf_cli.id, name: "Pop Disco Funk", genre: "Pop")
p3 = Playlist.create(user_id: mf_cli.id, name: "Homecoming 2020", genre: "EDM")
p4 = Playlist.create(user_id: ben.id, name: "Morning Workout", genre: "Heavy Metal")
p5 = Playlist.create(user_id: brendan.id, name: "Just Brokeup with my GF", genre: "Emo")
p6 = Playlist.create(user_id: ben.id, name: "Bebop", genre: "Jazz")

superstition = RSpotify::Track.search('Superstition', limit: 1, market: 'US').first
idiot = RSpotify::Track.search('American Idiot', limit: 1, market: 'US').first
glass = RSpotify::Track.search('Glass Island', limit: 1, market: 'US').first

PlaylistTrack.create(playlist_id: p1.id, track_id: superstition.id)
PlaylistTrack.create(playlist_id: p1.id, track_id: idiot.id)
PlaylistTrack.create(playlist_id: p5.id, track_id: glass.id)
PlaylistTrack.create(playlist_id: p2.id, track_id: glass.id)

PlaylistUser.create(playlist_id: p1.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p1.id, user_id: brendan.id)
PlaylistUser.create(playlist_id: p2.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p3.id, user_id: ben.id)
PlaylistUser.create(playlist_id: p5.id, user_id: ben.id)

binding.pry