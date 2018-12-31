require 'rails_helper'

describe Event, type: :model do
  before do
    @event = build(:event)
  end

  describe 'Associations' do
    it{ should belong_to :user }
    it{ should belong_to(:admin).class_name('User') }
    it{ should belong_to :facility }
    it{ should have_many :charges }
  end

  describe 'Validations' do
    it{ should validate_presence_of(:start_time) }
  end

  describe 'Methods' do
    describe '#facility' do
      it 'should save :admin facility (after save)' do
        @event.admin = create(:admin)
        @event.save!
        @event.facility.should == @event.admin.facility
      end
    end

    describe '#contact' do
      before do
        @old_facility_admin = create(:admin, active: false)
        @facility_admin = create(:admin)

        @event.facility.admins << [@old_facility_admin, @facility_admin]
      end

      it 'should return admin, if one exists' do
        admin = create(:admin)
        @event.update(admin_id: admin.id)
        @event.contact.should == admin
      end

      it 'should return @facility_admin, if no @event.admin' do
        @event.contact.should == @facility_admin
      end

      it "should return faciity's oldest active admin, if no admin exists" do
        new_facilty_admin = create(:admin)
        @event.facility.admins << new_facilty_admin
        @event.contact.should == @facility_admin
      end
    end
  end
end
