class CreatePlaylistTracks < ActiveRecord::Migration[5.2]
    def change 
        create_table :playlist_tracks do |t|
            t.integer :playlist_id
            t.integer :track_id
        end 
    end 
end 