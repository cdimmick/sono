class Event < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'
  belongs_to :facility, optional: true

  validates :start_time, presence: true
  validate :start_time, :starts_after_now, on: :create

  before_save :save_facility

  private

  def save_facility
    facility_id = admin.facility_id
  end

  def starts_after_now
    return unless start_time
    errors.add(:start_time, "must be after now") unless start_time >= Time.now
  end
end
