class Playlist < ActiveRecord::Base
    belongs_to :user #creator
    has_many :users #listeners
    has_many :tracks

    def tracks #returns array of URLs to tracks in the playlist
        PlaylistTrack.all.map do |track|
            if track.playlist_id == self.id
                song = RSpotify::Track.find(track.track_id).external_urls["spotify"]
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
end