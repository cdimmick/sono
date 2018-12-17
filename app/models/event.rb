class Event < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :facility
  # , optional: true

  has_many :charges

  validates :start_time, presence: true
  validate :start_time, :starts_after_now, on: :create

  def stream_token
    "#{id}-#{created_at.to_i}"
  end

  before_validation :set_facility

  private

  def set_facility
    self.facility_id = admin.facility_id if admin
  end

  def starts_after_now
    return unless start_time

    puts '............................'
    puts start_time.to_i
    puts start_time # this is in UTC time. So the time provided, is in UTC. Needs to be in local TZ
    puts Time.now.to_i
    puts Time.now
    puts '............................'

    unless Time.parse(start_time.to_s).to_i > Time.now.to_i
      errors.add(:start_time, "must be after now")
    end
  end
end
