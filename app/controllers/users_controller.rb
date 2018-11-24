class UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_facility
  before_action :set_users
  before_action :set_admins

  def index
  end

  private

  def set_facility
    @facility = Facility.find(params[:id])
  end

  def set_users
    @users = @facility.users
  end

  def set_admins
    @admins = @facility.admins
  end
end
