class Contact < ActiveRecord::Base
  # Table schema
  # t.belongs_to :user, index: true, foreign_key: true
  # t.string :first_name, default: ""
  # t.string :last_name, default: ""
  # t.string :phone_number
  # t.integer :friends_count, default: 0
  # t.boolean :invited, default: false
  # t.boolean :is_member, default: false
  belongs_to :user
  validates :phone_number, presence: true

  def point
    point = 5
    case self.friends_count
      when 0
        point = 5
      when 1..3
        point = 6
      when 4..6
        point = 7
      when 7..8
        point = 8
      when 9..10
        point = 9
      else
        point = 10
    end
  end
  def full_name
    [self.first_name, self.last_name].join(' ')
  end
end
