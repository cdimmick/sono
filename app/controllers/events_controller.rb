class EventsController < ApplicationController
  before_action :authenticate_admin!, except: [:show]
  before_action :authenticate_super_admin_has_acting_as_set!, except: [:show, :destroy]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_facility, except: [:show]
  before_action :set_users, only: [:new]

  def index
    @events = @facility.events
                       .where('start_time >= ?', Time.now)
                       .order(start_time: :asc)
  end

  def show
    @paid = true if params[:paid] == 'true'
  end

  def new
    @event = Event.new(user_id: params[:user_id])
  end

  # def edit
  # end

  def create
    @event = Event.new(event_params)
    @event.admin = current_user

    respond_to do |format|
      if @event.save
        UsersMailer.new_event(@event.id)
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # def update
  #   respond_to do |format|
  #     if @event.update(event_params)
  #       format.html { redirect_to @event, notice: 'Event was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @event }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @event.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
    params.require(:event).permit(:user_id, :facility_id, :admin_id, :start_time)
  end

  def set_facility
    @facility = current_user.facility
  end

  def set_users
    @users = @facility.users
  end
end
