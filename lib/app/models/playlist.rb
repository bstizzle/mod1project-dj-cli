require 'pry'

class Playlist < ActiveRecord::Base
    belongs_to :user #self.user (SINGULAR) returns the creator
    has_many :playlist_users
    has_many :users, through: :playlist_users #self.users (PLURAL) returns listeners

    def tracks #returns array of tracks in the playlist
        PlaylistTrack.all.map do |playTrack|
            if playTrack.playlist_id == self.id
                song = RSpotify::Track.find(playTrack.track_id).id
            end 
            song
        end.compact
    end

    def track_names
        self.tracks.map do |track|
            "#{RSpotify::Track.find(track).name} by: #{RSpotify::Track.find(track).artists.first.name}" 
        end 
    end

    def listen_to_tracks #prints urls to spotify tracks
        self.tracks.map{ |track| RSpotify::Track.find(track).external_urls["spotify"] }
    end 

    def creator #returns the user instance that created the playlist
        User.all.detect{|user| user.id == self.user_id}
    end

    def listeners #returns array of all users listening to this playlist
        PlaylistUser.all.map do |playUs|
            if playUs.playlist_id == self.id
                User.all.detect{|user| user.id == playUs.user_id}
            end 
        end.compact 
    end 

    def add_track(track) #add a track to the playlist
        PlaylistTrack.create(playlist_id: self.id, track_id: track.id)
    end

    def remove_track(track) #remove a track from the playlist
        PlaylistTrack.all.each do |playTrack|
            if playTrack.track_id == track.id
                PlaylistTrack.destroy(playTrack.id)
            end 
        end
    end

    def self.find_by_name(name) #returns array of playlists that have input string in their name
        self.all.select{ |playlist| playlist.name.downcase.include?(name.downcase) }
    end 

    def self.all_genres #returns array of all in-use genres
        self.all.map{|playlist| playlist.genre}.uniq
    end

    def self.find_by_genre(gen) #returns array of playlists that have input genre
        self.all.select{ |playlist| playlist.genre.downcase.include?(gen.downcase) } 
    end 

    def self.find_by_track(track_id) #returns array of playlists that include the input track
        self.all.select do |playlist|
            playlist.tracks.any?(track)
        end 
    end ###IMPORTANT, HAS TO TAKE TRACK ID AS INPUT, taking whole spotify track objs won't work

end