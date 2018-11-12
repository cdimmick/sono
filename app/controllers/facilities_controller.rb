class FacilitiesController < ApplicationController
  before_action :authenticate_super_admin!, only: [:new, :create, :edit, :update]
  before_action :set_facility, only: [:show, :edit, :update, :destroy]

  def index
    @facilities = Facility.all
  end

  def show
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
      format.json { head :no_content }
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
        :street, :street2, :street3, :number, :city, :state, :zip
      ]
    )
  end
end
