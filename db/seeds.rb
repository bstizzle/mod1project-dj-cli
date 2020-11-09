require 'pry'
require 'rspotify'

User.destroy_all
Playlist.destroy_all

#PlaylistUser.destroy_all
#PlaylistTrack.destroy_all

ben = User.create(username: 'ben', password: 'ben')
brendan = User.create(username: 'brendan', password: 'brendan')
mf_cli = User.create(username: 'MF CLI', password: '123')

p1 = Playlist.create(user_id: 1, name: "Easy Jazz", genre: "Jazz")
p2 = Playlist.create(user_id: 2, name: "Pop Disco Funk", genre: "Pop")
p3 = Playlist.create(user_id: 3, name: "Homecoming 2020", genre: "EDM")
p4 = Playlist.create(user_id: 4, name: "Morning Workout", genre: "Heavy Metal")
p5 = Playlist.create(user_id: 5, name: "Just Brokeup with my GF", genre: "Emo")