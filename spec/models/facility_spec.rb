require 'rails_helper'

describe Facility, type: :model do
  before do
    @facility = build(:facility)
  end

  describe 'Associations' do
    it{ should have_many(:admins).class_name('User') }

    it 'should destory admins on destroy' do
      @facility.save
      admin = create(:admin, facility_id: @facility.id)
      expect{ @facility.destroy }.to change{ User.exists?(admin.id) }
            .from(true).to(false)
    end

    it 'should NOT destroy Super Admins which have this facility set as #acting_as' do
      @facility.save!
      super_admin = create(:super_admin, facility_id: @facility.id)
      expect{ @facility.destroy }.not_to change{ User.exists?(super_admin.id) }
    end

    it{ should have_one :address }

    it 'should destory address on destroy' do
      @facility.save
      @facility.address = create(:address)
      address = @facility.address
      expect{ @facility.destroy }
            .to change{ address.persisted? }
            .from(true).to(false)
    end

    it{ should have_many :events }

    it 'should destroy events on destroy' do
      @facility.save
      event = create(:event)
      @facility.events << event
      expect{ @facility.destroy }
            .to change{ event.persisted? }
            .from(true).to(false)
    end

    it{ should have_many :patronages }
    it{ should have_many(:users).through(:patronages) }
  end

  describe 'Validations' do
    it{ should validate_presence_of :name }
  end

  describe 'Attributes' do
    specify ':active should default to true' do
      @facility.active.should == true
    end
  end
end
