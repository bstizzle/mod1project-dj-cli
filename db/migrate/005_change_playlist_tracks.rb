class CreatePlaylistTracks < ActiveRecord::Migration[5.2]
    def change 
        create_table :playlist_tracks do |t|
            t.integer :playlist_id
            t.string :track_id
        end 
    end 
end 