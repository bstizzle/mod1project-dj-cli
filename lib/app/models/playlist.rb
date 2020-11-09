class Playlist < ActiveRecord::Base
    belongs_to :user #creator
    has_many :users #listeners
    has_many :tracks

    def tracks
        PlaylistTrack.all.map do |track|
            if track.playlist_id == self.id
                song = RSpotify::Track.find(track.track_id).external_urls["spotify"]
            end 
            song
        end
    end

end