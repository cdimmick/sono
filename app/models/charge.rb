class Charge < ApplicationRecord
  belongs_to :event

  validates :email, presence: true
  validates :stripe_id, presence: true
  validates :amount, presence: true
end
