class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :friend_id
      t.string :status
      t.string :type
      t.timestamps null: false
    end
  end
end
