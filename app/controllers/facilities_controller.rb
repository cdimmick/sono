class FacilitiesController < ApplicationController
  before_action :authenticate_super_admin!, only: [:index, :new, :create, :destroy]
  before_action :authenticate_admin!, only: [:show, :edit, :update]
  before_action :set_facility, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user_is_facility_admin!, only: [:show, :edit, :update]

  def index
    @facilities = Facility.all
  end

  def show
    if user_is?('super_admin')
      current_user.update(facility_id: @facility.id)
    end
  end

  def new
    @facility = Facility.new
    @facility.build_address
  end

  def edit
  end

  def create
    @facility = Facility.new(facility_params)

    respond_to do |format|
      if @facility.save
        format.html { redirect_to @facility, notice: 'Facility was successfully created.' }
        format.json { render :show, status: :created, location: @facility }
      else
        format.html { render :new }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to @facility, notice: 'Facility was successfully updated.' }
        format.json { render :show, status: :ok, location: @facility }
      else
        format.html { render :edit }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @facility.destroy
    respond_to do |format|
      format.html { redirect_to facilities_url, notice: 'Facility was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end

  private

  def set_facility
    @facility = Facility.find(params[:id])
  end

  def facility_params
    params.require(:facility).permit(
      :name, :phone,
      address_attributes: [
        :street, :street2, :street3, :number, :city, :state, :zip, :timezone
      ]
    )
  end

  def authenticate_user_is_facility_admin!
    unless user_is?('super_admin') || (user_is?('admin') and current_user.facility == @facility)
      redirect_to root_path, alert: 'You must be a Super Admin to view that resource.'
    end
  end
end
