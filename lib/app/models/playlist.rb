class Playlist < ActiveRecord::Base
    belongs_to :user #creator
    has_many :users #listeners
    has_many :tracks

    def tracks #returns array of URLs to tracks in the playlist
        PlaylistTrack.all.map do |track|
            if track.playlist_id == self.id
                #might want to return track objects, and have separate method for getting the links?
                #song = RSpotify::Track.find(track.track_id).external_urls["spotify"]
                song = RSpotify::Track.find(track.track_id)
            end 
            song
        end
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

    def self.find_by_name(name) #returns array of playlists that have input string in their name
        self.all.select{ |playlist| playlist.name.downcase.include?(name.downcase) }
    end 

    def self.all_genres #returns array of all in-use genres
        self.all.map{|playlist| playlist.genre}.uniq
    end

    def self.find_by_genre(gen) #returns array of playlists that have input genre
        self.all.select{ |playlist| playlist.genre.downcase.include?(gen.downcase) } 
    end 

    def self.find_by_track(track) #returns array of playlists that include the input track
        self.all.select do |playlist|
            playlist.tracks.any?(track)
        end 
    end 
end