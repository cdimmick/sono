class UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :authenticate_super_admin_has_acting_as_set!, except: [:destroy]
  before_action :authenticate_super_admin!, only: [:destroy]
  before_action :set_facility
  before_action :set_users, except: [:edit, :new]
  before_action :set_admins, except: [:edit, :new]
  before_action :set_user, only: [:edit, :update, :destroy]
  # before_action :authenticate_admin_can_modify_user!, only: [:edit, :update]

  def index
  end

  def edit
    #TODO who should edit?
    #TODO spec
  end

  def update
    #TODO spec

    return unless user_can_set_role?

    if @user.update(user_params)
      redirect_to users_path, notice: "#{@user.name} has been created."
    else
      render :edit, alert: 'User could not be saved.'
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    return unless user_can_set_role?

    password = random_password
    @user.password = password
    @user.facilities << @facility if @user.role == 'user'
    @user.facility = @facility if @user.role == 'admin'

    if @user.save
      UsersMailer.new_user(@user.id, password).deliver_now
      redirect_to users_path, notice: "#{@user.role.titlecase} has been created"
    else
      render :new, alert: 'User could not be saved.'
    end
  end

  def destroy
    #TODO spec
    unless @user == current_user
      @user.destroy
      redirect_to users_path, notice: 'User has been destroyed.'
    else
      redirect_to users_path, notice: 'You cannot destroy yourself.'
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
    @admins = @facility.admins.admins # 2nd .admins is scope on User
  end

  def user_params
    params.require(:user).permit(
      :email, :name, :phone, :role
    )
  end

  def set_user
    @user = User.find(params[:id])
  end

  # def authenticate_super_admin_has_acting_as_set!
  #   return unless user_is?('super_admin')
  #
  #   if current_user.facility.nil?
  #     redirect_to facilities_path, alert: 'Please select a Facility to act as.'
  #   end
  # end

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
