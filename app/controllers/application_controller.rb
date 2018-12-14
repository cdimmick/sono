class ApplicationController < ActionController::Base
  include UserHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

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
    return unless user_is?('super_admin')

    if current_user.facility.nil?
      redirect_to facilities_path, alert: 'Please select a Facility to act as.'
    end
  end

  def authenticate_user_is_not_signed_in!
    if user_signed_in?
      redirect_to root_path, alert: 'You must sign out to view that resource.'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :facility_to_add])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:facility_to_add])
  end
end
