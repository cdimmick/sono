class Facility < ApplicationRecord
  validates :name, presence: true

  has_many :admins, class_name: 'User', dependent: :destroy

  has_one :address, as: :has_address, dependent: :destroy

  has_many :events, dependent: :destroy
end
