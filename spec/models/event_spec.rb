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
  end
end
