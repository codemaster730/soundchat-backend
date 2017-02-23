# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u1 = User.create email:'wira@email.com', user_name: 'wira', first_name: 'f', last_name: 'l', phone_number: '+8613050386450'
u2 = User.create email:'nick@email.com', user_name: 'nick', first_name: 'f', last_name: 'l', phone_number: '+15242382160'
Friendship.create(user_id: u1.id, friend_id: u2.id)
Friendship.create(user_id: u2.id, friend_id: u1.id)

User.create email:'test1@email.com', user_name: 'wira1', first_name: 'f1', last_name: 'l1', phone_number: '+60320322676'
User.create email:'test2@email.com', user_name: 'wira2', first_name: 'f2', last_name: 'l2', phone_number: '+60321178000'
User.create email:'test3@email.com', user_name: 'wira3', first_name: 'f3', last_name: 'l2', phone_number: '+60321417115'
User.create email:'test4@email.com', user_name: 'wira4', first_name: 'f4', last_name: 'l2', phone_number: '+60321418810'
User.create email:'test5@email.com', user_name: 'wira5', first_name: 'f5', last_name: 'l2', phone_number: '+60321799000'
User.create email:'test6@email.com', user_name: 'wira6', first_name: 'f6', last_name: 'l2', phone_number: '+60321178000'
