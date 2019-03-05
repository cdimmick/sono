class PagesController < ApplicationController
  def router
    case user_role
    when 'user'
      redirect_to user_path(current_user)
    when 'admin'
      redirect_to facility_path(current_user.facility)
    when 'super_admin'
      redirect_to facilities_path
    else
      redirect_to new_user_session_path
    end
  end
end
