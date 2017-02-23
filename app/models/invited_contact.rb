class InvitedContact < ActiveRecord::Base
  # Table schema

  # t.belongs_to :user, index: true, foreign_key: true
  # t.string :phone_number, default: ""
  # t.string :first_name
  validates :phone_number, presence: true
  validates :first_name, presence: true
  belongs_to :user

  after_create :reminder

  def reminder
    sender_first_name = self.user.first_name
    sender_full_name = self.user.full_name
    receiver_first_name = self.first_name
    @twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    reminder = "Hey #{receiver_first_name}! #{sender_full_name} would love to discover what music you're listening to.
                The app, Soundchat, shows your friends what music you listen to in real time.
                I guess you have good taste becauses #{sender_first_name} wants in.
                Allow #{sender_first_name} to discover your music via Soundchat on the App Store here: http://getsoundchat.com/15173736"
    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => self.phone_number,
      :body => reminder,
    )
    puts message.to
  end

  handle_asynchronously :reminder , :run_at => Proc.new { 3.seconds.from_now }
end
