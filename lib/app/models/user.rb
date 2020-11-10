class User < ActiveRecord::Base
    has_many :playlists #self.playlists returns playlists CREATED by the user

    def library #returns array of playlists the user is listening to
        PlaylistUser.all.map do |playUser|
            if playUser.user_id == self.id
                Playlist.all.detect{|playlist| playlist.id == playUser.playlist_id}
            end 
        end.compact 
    end    

    def add_playlist(playlist) #adds a new playlist to the user's library by creating a new PlaylistUser joiner
        PlaylistUser.create(playlist_id: playlist.id, user_id: self.id)
    end

    def remove_playlist(playlist) #removes a playlist from the user's library
        PlaylistUser.all.each do |playUser|
            if playUser.playlist_id == playlist.id
                PlaylistUser.destroy(playUser.id)
            end 
        end
    end

    def self.current_user(username)
        User.all.find{|user| user.username == username}
    end
   
end