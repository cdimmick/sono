# class SignUpsController < ApplicationController
#   before_action :set_admin
#   before_action :authenticate_user_is_not_signed_in!
#
#   def new
#     @user = User.new
#     @event = Event.new
#   end
#
#   def create
#     @user = User.new(
#       name: sign_up_params[:name],
#       email: sign_up_params[:email],
#       phone: sign_up_params[:phone],
#       start_time: sign_up_params[:start_time],
#       password: sign_up_params[:password],
#       password_confirmation: sign_up_params[:password_confirmation]
#     )
#
#     user_save = @user.save
#
#     @event = Event.new(
#       admin_id: @admin.id,
#       user_id: @user.id,
#       start_time: sign_up_params[:start_time]
#     )
#
#     event_save = @event.save
#
#     if user_save && event_save
#       UsersMailer.new_event(@event.id).deliver_now
#       sign_in(:user, @user)
#       redirect_to root_path, notice: 'Your acocunt has been created. Thank you.'
#     else
#       @user.destroy
#       @event.errors[:user].delete('must exist')
#       render :new
#     end
#   end
#
#   private
#
#   def sign_up_params
#     params.require(:sign_up).permit(
#       :name, :email, :phone, :start_time, :password, :password_confirmation
#     )
#   end
#
#   def set_admin
#     @admin = User.find(params[:id])
#   end
# end
