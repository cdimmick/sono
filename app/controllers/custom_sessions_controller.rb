class CustomSessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    super

    facility_id = params.dig(:user, :facility_to_add)

    return if facility_id.blank?

    current_user.facilities << Facility.find(facility_id)
    # current_user.save!
  end
end
