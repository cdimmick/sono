class Event < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :facility

  has_many :charges

  validates :start_time, presence: true

  def stream_token
    "#{id}-#{created_at.to_i}"
  end

  def local_time
    #TODO spec
    start_time.in_time_zone(facility.address.timezone)
  end

  before_validation :set_facility
  after_validation :set_start_time



  private

  def set_start_time
    #TODO Spec
    return unless facility && facility.address

    timezone = self.facility.address.timezone
    start_time_string = self.start_time.strftime('%vT%R')
    time_in_zone = ActiveSupport::TimeZone[timezone].parse(start_time_string)

    self.start_time = time_in_zone
  end

  def set_facility
    return unless admin

    self.facility_id = admin.facility_id
  end
end
