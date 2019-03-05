class Event < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :facility

  has_many :charges

  validates :start_time, presence: true

  def stream_token
    id
  end


  def local_time
    start_time.in_time_zone(facility.timezone)
  end

  def contact
    admin || facility.admins.active.first
  end

  def stream_url
    "#{ENV.fetch('WOWZA_STREAM_BASE_URL')}/#{self.stream_token}/playlist.m3u8"
  end

  before_validation :set_facility
  after_validation :set_start_time
  before_create :set_tokens

  private

  def set_tokens
    self.download_token = random_token
  end

  def random_token
    s = ''
    20.times do
      s += %w|a b c d e f g h i j k l m n o p q r s t u v w x y z
              A B C D E F G H I J K L M N O P Q R S T U V W Z Y Z
              1 2 3 4 5 6 7 8 9 0 @ # $ % ^ *|.sample
    end

    s
  end

  def set_start_time
    return unless facility && facility.timezone && start_time

    timezone = facility.timezone
    start_time_string = start_time.strftime('%vT%R')
    time_in_zone = ActiveSupport::TimeZone[timezone].parse(start_time_string)

    self.start_time = time_in_zone
  end

  def set_facility
    return unless admin

    self.facility_id = admin.facility_id
  end
end
