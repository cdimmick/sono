require 'rails_helper'

describe Event, type: :model do
  before do
    @event = build(:event)
    @facility = @event.facility
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

    describe '#local_time' do
      it "should return time as local to the Facility's timezone" do
        @event.facility.address.update(timezone: 'America/Los_Angeles')
        @event.update(start_time: '2000-12-12T9:00')
        @event.local_time.strftime('%FT%T%z').should == '2000-12-12T09:00:00-0800'
      end
    end
  end # Methods

  describe 'Idioms' do
    describe 'Download Token' do
      it 'Should create a random download_token on create' do
        @event.download_token.should == nil
        @event.save!
        @event.download_token.length.should == 20
      end
    end

    describe 'Saving Start Time' do
      it 'should save start_time in timezone of @event.facility' do
        @event.facility.address.update(timezone: 'America/Los_Angeles')
        @event.update(start_time: '2018-12-12T13:00')
        @event.start_time.in_time_zone(@event.facility.timezone)
              .strftime('%FT%T%z').should == '2018-12-12T13:00:00-0800'
      end
    end
  end # Idioms
end
