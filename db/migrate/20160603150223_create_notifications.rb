class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :message
      t.string :sender_id
      t.string :notif_type

      t.timestamps null: false
    end
  end
end
