module UserHelper
  def user_role
    user_signed_in? ? current_user.role : 'guest'
  end

  def user_can?(role)
    user_signed_in? && current_user.can?(role)
  end

  def user_is?(role)
    user_role == role
  end
end
