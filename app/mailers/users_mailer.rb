class UsersMailer < ApplicationMailer
  def new_user(user_id, password)
    @passord = password
    @user = User.find(user_id)

  end
end
