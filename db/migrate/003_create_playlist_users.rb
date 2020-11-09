class CreatePlaylistUsers < ActiveRecord::Migration[5.2]
    def change 
        create_table :playlist_users do |t|
            t.integer :playlist_id
            t.integer :user_id
        end 
    end 
end 