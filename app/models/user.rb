class User < ApplicationRecord
  ROLES = %w|user admin super_admin|

  validates :role, presence: true, inclusion: {in: ROLES}

  belongs_to :facility, optional: true, inverse_of: 'Admins'

  has_many :patronages
  has_many :facilities, through: :patronages

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
