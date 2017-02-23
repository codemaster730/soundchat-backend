class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :user_name, default: ""
      t.string :first_name, default: ""
      t.string :last_name, default: ""
      t.string :phone_number
      t.string :digital_code
      t.string :token
      t.string :device_token, default: ""
      t.integer :badge_count, default: 0, null: false
      t.integer :point, default: 0
      t.boolean :verified

      t.timestamps null: false
    end
  end
end
