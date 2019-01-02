class UsersController < ApplicationController
  before_action :authenticate_super_admin!, only: [:admins]
  before_action :authenticate_admin!, except: [:show]
  before_action :authenticate_super_admin_has_acting_as_set!, except: [:deactivate, :admins, :show]
  before_action :set_facility, except: [:deactivate, :admins, :show]
  before_action :set_users, except: [:edit, :new, :destroy, :deactivate, :admins, :show]
  before_action :set_admins, except: [:edit, :new, :destroy, :deactivate, :admins, :show]
  before_action :set_user, only: [:edit, :update, :destroy, :deactivate, :show]

  def show
    @event = Event.new
  end

  def admins
    @users = User.admins + User.super_admins
  end

  def index
  end

  def edit
  end

  def update
    return unless user_can_set_role?

    if @user.update(user_params)
      redirect_to users_path, notice: "#{@user.name} has been updated."
    else
      render :edit, alert: 'User could not be saved.'
    end
  end

  def new
    @user = User.new
  end

  def create
    new_user = true

    if user_params[:role] == 'user'
      # Because User can have multiple Facilities, one Facility may think they
      # are signing a User up, but the User already exists, so UPDATE User.
      @user = User.find_or_create_by(email: user_params[:email])
      @user.assign_attributes(user_params)
      new_user = @user.new_record?
    else
      @user = User.new(user_params)
    end

    return unless user_can_set_role?

    @user.facilities << @facility if @user.role == 'user'
    @user.facility = @facility if @user.role == 'admin'

    if new_user
      password = random_password
      @user.password = password
    end

    if @user.save
      UsersMailer.new_user(@user.id, password).deliver_now if new_user

      notice = "#{@user.role.titlecase} has been created"
      if @user.role == 'user'
        redirect_to "#{new_event_path}?user_id=#{@user.id}", notice: notice
      else
        redirect_to users_path, notice: notice
      end
    else
      render :new
    end
  end

  def destroy
    if @user.role == 'user'
      if @user.facilities.include?(@facility)
        @facility.users.delete(@user)
        redirect_to users_path, notice: 'User has been destroyed.'
      else
        if user_is?('super_admin')
          redirect_to facilities_path, alert: 'You must selet a Facility to act as.'
        else
          redirect_to root_path, alert: 'You must be a Super Admin to view that resource.'
        end
      end
    else
      redirect_to root_path, alert: "You cannot destroy #{@user.role.titlecase}s."
    end
  end

  def deactivate
    if @user.facility == current_user.facility || user_is?('super_admin')
      @user.update(active: false)
      redirect_to users_path, notice: "#{@user.role.titlecase} has been deactivated."
    else
      redirect_to root_path, alert: 'You must be a Super Admin to view that resource.'
    end
  end

  private

  def set_facility
    @facility = current_user.facility
  end

  def set_users
    @users = @facility.users.order(updated_at: :desc)
  end

  def set_admins
    @admins = @facility.admins.admins.active # 2nd .admins is scope on User
  end

  def user_params
    params.require(:user).permit(
      :email, :name, :phone, :role
    )
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_can_set_role?
    if User::ROLES.index(@user.role) > User::ROLES.index(current_user.role)
      redirect_to users_path, alert: 'You cannot create that Role.'
      false
    else
      true
    end
  end

  def random_password
    chars = %w|a b c d e f g h i j k l m n o p q r s t u v w x y z
               A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
               1 2 3 4 5 6 7 8 9 0 @ $ % ^ & * ( )|
    pw = ''
    20.times{ pw += chars.sample }
    pw
  end
end
