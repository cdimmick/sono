require 'rails_helper'

describe User, type: :model do
  before do
    @user = build(:user)
    @admin = build(:admin)
    @super_admin = build(:super_admin)
  end

  describe 'Associations' do
    it{ should belong_to(:facility).inverse_of(:admins) }

    it{ should have_many :patronages }
    it{ should have_many(:facilities).through(:patronages) }

    it{ should have_many(:events) }
    it{ should have_many(:events).inverse_of(:admin) }
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

    specify ':active should default to true' do
      @user.active.should == true
    end
  end

  describe 'Methods' do
    describe '#can?(role)' do
      it 'should return true if user.role is greater than role param' do
        @user.can?('user').should == true
        @user.can?('admin').should == false

        @admin.can?('user').should == true
        @admin.can?('admin').should == true
        @admin.can?('super_admin').should == false

        @super_admin.can?('super_admin').should == true
      end
    end
  end
end
