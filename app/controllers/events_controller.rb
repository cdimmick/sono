class EventsController < ApplicationController
  before_action :authenticate_admin!, except: [:show, :create, :edit, :update, :invite, :download]
  before_action :authenticate_user!, only: [:create, :edit, :update, :invite]
  before_action :authenticate_super_admin_has_acting_as_set!, except: [:show, :destroy, :download]

  before_action :set_event, only: [:show, :edit, :update, :destroy, :invite, :download]
  before_action :set_facility, except: [:show, :update, :invite, :download]
  before_action :set_users, only: [:new]

  def download
    if @event.download_token == params[:token]
      redirect_to @event.download_url
    else
      redirect_to root_path, alert: 'You are not allowed to view that resource.'
    end
  end

  def invite
    if @event.user != current_user
      redirect_to root_path, alert: 'Only the Event User may view this resource.'
      return
    end

    params[:emails].split(/, ?/).each do |email|
      GuestsMailer.invite(@event.id, email).deliver_later
    end

    redirect_to @event, notice: "#{params[:emails]} will be invited right away."
  end

  def index
    @events = @facility.events
                       .where('start_time >= ?', Time.now)
                       .order(start_time: :asc)
  end

  def show
    respond_to do |format|
      format.html do
        @password_required = @event.password.blank? ? false : true
        @password_required = false if @event.user == current_user
        @password_required = false if user_signed_in? && current_user.facility == @event.facility
        @password_required = false if user_is?('super_admin')
        render :show
      end

      format.js do
        if event_params[:password] == @event.password
          render :show
        else
          render json: {error: 'password incorrect'}, status: :unprocessable_entity
        end
      end
    end
  end

  def new
    @event = Event.new(user_id: params[:user_id])
  end

  def edit
    if user_is?('admin') && current_user.facility != @event.admin.facility ||
       user_is?('user') && current_user != @event.user
      redirect_to root_path, alert: 'You are not allowed to edit that resource.'
    else
      render :edit
    end
  end

  def create
    if event_params[:user_attributes] && event_params[:user_id].blank?
      # So if this Event is created with a NEW User.
      # This will assign a random_password even if a password is passed with the params.
      password = random_password
      params[:event][:user_attributes][:password] = random_password
      @new_user = true
    end

    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        UsersMailer.new_event(@event.id).deliver_later
        FacilitiesMailer.new_event(@event.id).deliver_later unless user_is?('admin')
        UsersMailer.new_user(@event.user.id, password).deliver_later if @new_user


        format.html { redirect_to @event, notice: 'Event was successfully created.' }
      else
        format.html do
          if user_is?('user')
            @user = current_user
            render 'users/show'
          else
            set_users
            render :new
          end
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html do
          if user_is?('user') && @event.user != current_user
            redirect_to root_path, alert: 'You must be an Admin to view that resource.'
          else
            UsersMailer.changed_event(@event.id).deliver_later
            FacilitiesMailer.changed_event(@event.id).deliver_later

            redirect_path = user_is?('user') ? user_path(@event.user) : event_path(@event)
            redirect_to redirect_path, notice: 'Event was updated.'
          end
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    if user_is?('admin') && @event.facility != current_user.facility
      redirect_to root_path, alert: 'You must be a Super Admin to view that resource.'
      return
    end

    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :user_id, :facility_id, :admin_id, :start_time, :password,
      user_attributes: [:name, :email, :phone, :password]
    )
  end

  def set_facility
    @facility = current_user.facility
  end

  def set_users
    @users = @facility.users
  end
end
