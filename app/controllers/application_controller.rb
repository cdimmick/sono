class ApplicationController < ActionController::Base
  include UserHelper

  def authenticate_super_admin!
    unless user_can?('super_admin')
      redirect_to root_url, alert: 'You must be a Super Admin to view that resource.'
    end
  end

  def authenticate_admin!
    unless user_can?('admin')
      redirect_to root_url, alert: 'You must be an Admin to view that resource.'
    end
  end


  def authenticate_super_admin_has_acting_as_set!
    if current_user.facility.nil?
      redirect_to facilities_path, alert: 'Please select a Facility to act as.'
    end
  end

  def authenticate_user_is_not_signed_in!
    if user_signed_in?
      redirect_to root_path, alert: 'You must sign out to view that resource.'
    end
  end
end
