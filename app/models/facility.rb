class Facility < ApplicationRecord
  validates :name, presence: true

  has_many :admins, class_name: 'User'

  has_one :address, as: :has_address, dependent: :destroy
  accepts_nested_attributes_for :address

  validates :address, presence: true

  has_many :events, dependent: :destroy

  has_many :patronages
  has_many :users, through: :patronages

  delegate :timezone, to: :address

  after_destroy :destroy_admins!

  private

  def destroy_admins!
    User.admins.where(facility_id: id).destroy_all
  end
end
