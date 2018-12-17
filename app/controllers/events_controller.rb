class EventsController < ApplicationController
  before_action :authenticate_admin!, except: [:show, :create, :edit, :update, :invite]
  before_action :authenticate_user!, only: [:create, :edit, :update, :invite]
  before_action :authenticate_super_admin_has_acting_as_set!, except: [:show, :destroy]

  before_action :set_event, only: [:show, :edit, :update, :destroy, :invite]
  before_action :set_facility, except: [:show, :update, :invite]
  before_action :set_users, only: [:new]

  def invite
    params[:emails].split(/, ?/).each do |email|
      GuestsMailer.invite(@event.id, email).deliver_later
    end

    redirect_to @event, notice: 'Your Guests have been invited.'
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
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        UsersMailer.new_event(@event.id).deliver_later
        FacilitiesMailer.new_event(@event.id).deliver_later unless user_is?('admin')
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

            redirect_path = user_is?('user') ? user_path(@event.user) : events_path
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
      :user_id, :facility_id, :admin_id, :start_time, :password
    )
  end

  def set_facility
    @facility = current_user.facility
  end

  def set_users
    @users = @facility.users
  end
end
