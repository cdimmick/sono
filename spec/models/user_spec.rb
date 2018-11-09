require 'rails_helper'

describe User, type: :model do
  before do
    @user = build(:user)
    @admin = build(:admin)
    @super_admin = build(:super_admin)
  end

  describe 'Associations' do
    it{ should belong_to(:facility).inverse_of('Admins') }

    it{ should have_many :patronages }
    it{ should have_many(:facilities).through(:patronages) }
  end

  describe 'Validations' do
    it{ should validate_presence_of :email }

    it{ should validate_presence_of :password }

    it{ should validate_presence_of :role }
    it{ should validate_inclusion_of(:role).in_array(User::ROLES) }
  end

  describe 'Attributes' do
    specify ':role should default to "user"' do
      @user.role.should == 'user'
    end
  end
end
