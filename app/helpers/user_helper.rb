module UserHelper
  def user_role
    user_signed_in? ? current_user.role : 'guest'
  end
end
