class User < ApplicationRecord
  ROLES = %w|user admin super_admin|

  validates :role, presence: true, inclusion: {in: ROLES}

  belongs_to :facility, optional: true, inverse_of: :admins

  has_many :patronages
  has_many :facilities, through: :patronages

  has_many :events
  has_many :events, inverse_of: :admin

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
