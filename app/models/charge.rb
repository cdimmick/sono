class Charge < ApplicationRecord
  belongs_to :event

  validates :email, presence: true
  validates :stripe_token, presence: true
end
