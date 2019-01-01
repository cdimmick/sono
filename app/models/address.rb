class Address < ApplicationRecord
  STATES = {"AL"=>"Alabama", "AK"=>"Alaska", "AZ"=>"Arizona", "AR"=>"Arkansas",
            "CA"=>"California", "CO"=>"Colorado", "CT"=>"Connecticut",
            "DC"=>"Washington DC", "DE"=>"Delaware", "FL"=>"Florida",
            "GA"=>"Georgia", "HI"=>"Hawaii", "ID"=>"Idaho", "IL"=>"Illinois",
            "IN"=>"Indiana", "IA"=>"Iowa", "KS"=>"Kansas", "KY"=>"Kentucky",
            "LA"=>"Louisiana", "ME"=>"Maine", "MD"=>"Maryland",
            "MA"=>"Massachusetts", "MI"=>"Michigan", "MN"=>"Minnesota",
            "MS"=>"Mississippi", "MO"=>"Missouri", "MT"=>"Montana",
            "NE"=>"Nebraska", "NV"=>"Nevada", "NH"=>"New Hampshire",
            "NJ"=>"New Jersey", "NM"=>"New Mexico", "NY"=>"New York",
            "NC"=>"North Carolina", "ND"=>"North Dakota", "OH"=>"Ohio",
            "OK"=>"Oklahoma", "OR"=>"Oregon", "PA"=>"Pennsylvania",
            "RI"=>"Rhode Island", "SC"=>"South Carolina", "SD"=>"South Dakota",
            "TN"=>"Tennessee", "TX"=>"Texas", "UT"=>"Utah", "VT"=>"Vermont",
            "VA"=>"Virginia", "WA"=>"Washington", "WV"=>"West Virginia",
            "WI"=>"Wisconsin", "WY"=>"Wyoming"}

  belongs_to :has_address, polymorphic: true, optional: true

  validates :street, presence: true
  validates :city, presence: true
  validates :zip, presence: true
  validates :state, presence: true

  validates :state, inclusion: {in: STATES.keys}

  geocoded_by :to_s

  after_validation :geocode
  after_validation :set_timezone

  def full_state
    STATES[state]
  end

  def to_s(street_delineator = ', ')
    s = ''
    s += street.to_s
    s += " #{number}" unless number.blank?
    s += ", #{street2}" unless street2.blank?
    s += ", #{street3}" unless street3.blank?
    s += street_delineator
    s += "#{city}, #{state} #{zip}"
    s
  end

  private

  def set_timezone
    return if errors.count > 0
    self.timezone = Timezone.lookup(latitude, longitude).name
  end
end
