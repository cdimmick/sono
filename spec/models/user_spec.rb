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

    it{ should validate_presence_of :name }

    specify 'Admin must have an associated Facility' do
      @admin.update(facility_id: nil)
      @admin.valid?.should == false
      @admin.errors[:facility].include?('cannot be blank').should == true
    end
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

    describe '#acting_as' do
      it 'should return the facility associated with the super_admin' do
        facility = create(:facility)
        @super_admin.facility = facility
        @super_admin.acting_as.should == facility
      end
    end
  end

  describe 'Scopes' do
    before do
      @user.save!
      @admin.save!
      @super_admin.save!
    end
    specify ':users should return regular users' do
      User.users.should == [@user]
    end

    specify ':admins should return admins' do
      User.admins.should == [@admin]
    end

    specify ':super_admins should return regular super_admins' do
      User.super_admins.should == [@super_admin]
    end
  end

  # describe 'Idioms' do
  #
  # end
end
