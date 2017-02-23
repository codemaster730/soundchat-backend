module Endpoints
  class Accounts < Grape::API
    resource :accounts do

      get :ping do
        { ping: "accounts test"}
      end

      # Create Account using phone_number
      # POST: /api/v1/accounts
      # parameters:
      #   phone_number:   String *required
      # results:
      #   if success
      #     return {state: 'success',  data: '1'}
      #   else
      #     return {state: 'failure',  data: error_message}
      post do
        user = User.find_by_phone_number params[:phone_number]
        if user.present?
          user.update(digital_code: User::digital_code, verified: false)
          user.reminder
          {state: :success, data: user.id}
        else
          user = User.new(phone_number: params[:phone_number], digital_code: User::digital_code, verified: false)
          if user.save()
            {state: :success, data: user.id}
          else
            {state: :failure, data: user.errors.messages}
          end
        end

      end

      # Verify Account using phone_number and digital_code
      # POST: /api/v1/accounts/verify
      # parameters:
      #   phone_number:   String *required
      #   digital_code:   Number *required
      # results:
      #   if success
      #     return {state: 'success',  data: user_info}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :verify do
        user = User.find_by_phone_number params[:phone_number]
        if user.present?
          if user.digital_code == params[:digital_code]
            user.generate_token
            user.verified = true
            user.save
            invite_contacts = InvitedContact.where(phone_number: params[:phone_number])
            invite_contacts.each do |inv_contact|
              inv_contact.user.contacts.find_by_phone_number(params[:phone_number]).delete
              inv_contact.user.add_friend user
              inv_contact.user.increase_point 50, user
            end
            return {state: 'success',  data: user.info_by_json}
          else
            return {state: :failure, data: "Sorry for inconvenience, we are not able to verify this number, please try again."}
          end
        else
          return {state: :failure, data: "Your phone number doesn't exist"}
        end
      end

      # Get User info
      # GET: /api/v1/accounts
      # parameters:
      #   token:      String * required
      # results:
      #   if success
      #     return {state: 'success',  data: user_info}
      #   else
      #     return {state: 'failure',  data: error_message}
      get do
        user = User.find_by_token params[:token]
        if user.present?
            {state: :success, data: user.info_by_json}
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end


      # Set full name
      # POST: /api/v1/accounts/set_full_name
      # parameters:
      #   token:      String * required
      #   first_name: String
      #   last_name:  String
      # results:
      #   if success
      #     return {state: 'success',  data: user_id}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :set_full_name do
        user = User.find_by_token params[:token]
        if user.present?
          if(user.update(first_name: params[:first_name], last_name: params[:last_name]))
            {state: :success, data: user.id}
          else
            {state: :failure, data: user.errors.messages}
          end

        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Set user name
      # POST: /api/v1/accounts/set_user_name
      # parameters:
      #   token:      String * required
      #   user_name:  String * required
      #   device_token:   String *required

      # results:
      #   if success
      #     return {state: 'success',  data: user_id}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :set_user_name do
        user = User.find_by_token params[:token]
        if user.present?
          if(user.update(user_name: params[:user_name], device_token: params[:device_token]))
            {state: :success, data: user.id}
          else
            {state: :failure, data: user.errors.messages}
          end

        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Find friends via contact list
      # POST: /api/v1/accounts/find_friends
      # parameters:
      #   token:          String * required
      #   contacts:       String splited by ',' "+11111:Wira1 coon, 2354:Wira2"
      #
      # results:
      #   if success
      #     return {state: 'success',  data: {friends: friend_list, contacts: contact_list}}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :find_friends do
        user = User.find_by_token params[:token]
        if user.present?
          friends = []
          contacts = params[:contacts].split(",").map{|cc| cc.split(':')}
          phone_numbers = contacts.map{|cc| cc[0]}
          ids_by_contact = User.find_by_contact_numbers(phone_numbers)
          ids_by_contact.delete_if{|uid| uid == user.id}
          user.update_contacts contacts
          if ids_by_contact != nil and ids_by_contact.count > 0
            friend_conditions = ids_by_contact.map{|u_id| {user_id:u_id,friend_id:user.id}}
            if friend_conditions.count > 0
              user.add_friends friend_conditions
            end
          end
          {state: :success, data: {friends: user.friends_by_json, contacts: user.no_member_of_contacts_by_json}}
        else
            {state: :failure, data: "Can't find this user for this token  '#{params[:token]}'"}
        end
      end
      # Get my friends
      # GET: /api/v1/accounts/friends
      # parameters:
      #   token:        String * required
      #
      # results:
      #   if success
      #     return {state: 'success',  data: {friend_list}}
      #   else
      #     return {state: 'failure',  data: error_message}
      get :friends do
        user = User.find_by_token params[:token]
        if user.present?
          if user.friends.count > 0
            {state: :success, data: user.friends_by_json}
          else
            {state: :success, data: []}
          end
        else
            {state: :failure, data: "Can't find this user for this token  '#{params[:token]}'"}
        end
      end
      # DELETE friendS
      # DELETE: /api/v1/accounts/friends
      # parameters:
      #   token:        String * required
      #   friend_id     String * required
      # results:
      #   if success
      #     return {state: 'success',  data: {friend_list}}
      #   else
      #     return {state: 'failure',  data: error_message}
      delete :friends do
        user = User.find_by_token params[:token]
        if user.present?
          if user.friends.count > 0
            friend = user.friendships.find_by_friend_id(params[:friend_id])
            if friend.delete
              {state: :success, data: "deleted #{friend.id}"}
            else
              {state: :failure, data: friend.errors.messagess}
            end
          else
            {state: :failure, data: "can't find friend"}
          end
        else
            {state: :failure, data: "Can't find this user for this token  '#{params[:token]}'"}
        end
      end
      # Invite friend request by user name
      # POST: /api/v1/accounts/invite_friend
      # parameters:
      #   token:        String * required
      #   user_name:    String * required
      #
      # results:
      #   if success
      #     return {state: 'success',  data: user_id}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :invite_friend do
        user = User.find_by_token params[:token]
        if user.present?
          friend = User.find_by_user_name params[:user_name]
          if friend
            if user.id == friend.id
              {state: :failure, data: "Can't invite to this user #{params[:user_name]}"}
            else
              data = user.invite_friend friend
              {state: :success, data: data}
            end
          else
            {state: :failure, data: "Can't find friend '#{params[:user_name]}' on app"}
          end
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Invite friend request by phone_number
      # POST: /api/v1/accounts/invite_friend_by_contact_phone_number
      # parameters:
      #   token:          String * required
      #   phone_number:   String * required
      #   first_name:     String * required
      #
      # results:
      #   if success
      #     return {state: 'success',  data: users point}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :invite_friend_by_contact_phone_number do
        user = User.find_by_phone_number params[:phone_number]
        if user.present?
          {state: :failure, data: "Can't send invite because this phone_number is soundchat member"}
        else
          user = User.find_by_token params[:token]
          contact = user.contacts.find_by_phone_number params[:phone_number]
          if user.present? and contact.present?
            if contact.invited
              {state: :failure, data: "Already sent invite"}
            else
              invite_friend = user.invited_contacts.new phone_number: params[:phone_number], first_name: params[:first_name]
              if invite_friend.save
                contact.update invited: true
                user.increase_point contact.point
                {state: :success, data: user.point}
              else
                {state: :failure, data: invite_friend.errors.messages}
              end
            end
          else
              {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
          end
        end

      end

      # Accept or Decline friend request
      # POST: /api/v1/accounts/accept_request
      # parameters:
      #   token:        String * required
      #   friend_id     String * required
      #   state:        Boolean * required
      #
      # results:
      #   if success
      #     return {state: 'success',  data: {friend_list}}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :accept_request do
        user = User.find_by_token params[:token]
        if user.present?
          friend = User.find_by_id params[:friend_id]
          if friend
            user.accept_request friend, params[:state]
            {state: :success, data: user.friends_by_json}
          else
            {state: :failure, data: "Can't find friends on app"}
          end
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Reset badge count
      # POST: /api/v1/accounts/reset_badge_count
      # parameters
      #   token:        String * required
      # results:
      #   if success
      #     return {state: 'success',  data: success_message}
      #   else
      #     return {state: 'failure',  data: error_message}
      post :reset_badge_count do
        user = User.find_by_token params[:token]
        if user.present?
          if user.update(badge_count: 0)
            {state: :success, data: "success"}
          else
            {state: :failure, data: "Can't reset"}
          end
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Get notifications
      # GET: /api/v1/accounts/notifications
      # parameters
      #   token:        String * required
      # results:
      #   if success
      #     return {state: 'success',  data: success_message}
      #   else
      #     return {state: 'failure',  data: error_message}
      get :notifications do
        user = User.find_by_token params[:token]
        if user.present?
            {state: :success, data: user.notifications_by_json}
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

      # Delete notification
      # DELETE: /api/v1/accounts/notification
      # parameters
      #   token:            String * required
      #   notification_id:  String * required
      # results:
      #   if success
      #     return {state: 'success',  data: success_message}
      #   else
      #     return {state: 'failure',  data: error_message}
      delete :notification do
        user = User.find_by_token params[:token]
        notif = user.notifications.find(params[:notification_id])
        if user.present?
          if notif.present? and notif.destroy
            {state: :success, data: notif.id}
          else
            {state: :failure, data: "Can't find this notification  '#{params[:notification_id]}'"}
          end
        else
            {state: :failure, data: "Can't find this user for this token '#{params[:token]}'"}
        end
      end

    end
  end
end
