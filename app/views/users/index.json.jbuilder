json.array!(@users) do |user|
  json.extract! user, :id, :email, :user_name, :firs_name, :last_name, :phone_number, :digital_code, :verified
  json.url user_url(user, format: :json)
end
