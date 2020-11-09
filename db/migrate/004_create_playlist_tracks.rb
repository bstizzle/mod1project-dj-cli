class CreatePlaylistTracks < ActiveRecord::Migration[5.2]
    def change 
        create_table :playlists do |t|
            t.integer :playlist_id
            t.integer :user_id
        end 
    end 
end 