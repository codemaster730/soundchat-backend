class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :first_name, default: ""
      t.string :last_name, default: ""
      t.string :phone_number
      t.integer :friends_count, default: 0
      t.boolean :invited, default: false
      t.boolean :is_member, default: false

      t.timestamps null: false
    end
  end
end
