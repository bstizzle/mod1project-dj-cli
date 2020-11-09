class ChangePlaylistTracks < ActiveRecord::Migration[5.2]
    def change 
        change_table :playlist_tracks do |t|
            t.change :track_id, :string 
        end 
    end 
end 