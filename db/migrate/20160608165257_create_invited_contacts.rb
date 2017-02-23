class CreateInvitedContacts < ActiveRecord::Migration
  def change
    create_table :invited_contacts do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :phone_number
      t.string :first_name

      t.timestamps null: false
    end
  end
end
