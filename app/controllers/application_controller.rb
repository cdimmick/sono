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
end
