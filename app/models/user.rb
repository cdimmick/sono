class User < ApplicationRecord
  ROLES = %w|user admin super_admin|

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable,
         :rememberable, :validatable, :registerable

  validates :role, presence: true, inclusion: {in: ROLES}

  validates :name, presence: true

  belongs_to :facility, optional: true, inverse_of: :admins

  has_many :patronages
  has_many :facilities, through: :patronages

  has_many :events
  has_many :events, inverse_of: :admin

  def active_for_authentication?
    super && self.active?
  end

  def can?(role)
    ROLES.index(self.role) >= ROLES.index(role)
  end

  def acting_as
    facility
  end

  def acting_as=(facility)
    raise ArgumentError, "Only Super Admins should use this method" unless role == 'super_admin'
    update(facility_id: facility.id)
  end

  def facility_to_add=(id)
    return if id.blank?
    facilities << Facility.find(id)
  end

  before_validation :admin_validations

  scope :users, -> { where(role: 'user') }
  scope :admins, -> { where(role: 'admin') }
  scope :super_admins, -> { where(role: 'super_admin') }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  private

  def admin_validations
    return unless role == 'admin'
    errors.add('facility', 'cannot be blank') if facility.nil?
  end
end
