class Event < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'
  belongs_to :facility, optional: true

  has_many :charges

  validates :start_time, presence: true
  validate :start_time, :starts_after_now, on: :create

  def stream_token
    "#{id}-#{created_at.to_i}"
  end

  before_save :set_facility

  private

  def set_facility
    self.facility_id = admin.facility_id
  end

  def starts_after_now
    return unless start_time
    errors.add(:start_time, "must be after now") unless start_time >= Time.now
  end
end
