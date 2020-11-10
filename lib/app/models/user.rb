class User < ActiveRecord::Base
    has_many :playlists #self.playlists returns playlists CREATED by the user
    has_many :tracks, through: :playlists

    def library #returns array of playlists the user is listening to
        PlaylistUser.all.map do |playUs|
            if playUs.user_id == self.id
                Playlist.all.detect{|playlist| playlist.id == playUs.playlist_id}
            end 
        end.compact 
    end    

    def add_playlist(playlist) #adds a new playlist to the user's library by creating a new PlaylistUser joiner
        PlaylistUser.create(playlist.id, self.id)
    end
end