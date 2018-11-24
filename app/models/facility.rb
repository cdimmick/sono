class Facility < ApplicationRecord
  validates :name, presence: true

  has_many :admins, class_name: 'User', dependent: :destroy

  has_one :address, as: :has_address, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many :events, dependent: :destroy

  has_many :patronages
  has_many :users, through: :patronages
end
