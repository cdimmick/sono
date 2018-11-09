class Facility < ApplicationRecord
  validates :name, presence: true

  has_many :admins, class_name: 'User'

  has_one :address, as: :has_address
end
