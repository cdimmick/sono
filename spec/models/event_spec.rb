require 'rails_helper'

describe Event, type: :model do
  before do
    @event = build(:event)
  end

  describe 'Associations' do
    it{ should belong_to :user }
    it{ should belong_to(:admin).class_name('User') }
    it{ should belong_to :facility }
  end

  describe 'Validations' do
    it{ should validate_presence_of(:start_time) }

    describe ':start_time' do
      it 'must follow now on create' do
        @event.update(start_time: Time.now - 1.second)
        @event.valid?.should == false
        @event.errors.messages[:start_time].include?('must be after now').should == true
      end

      it 'may be before now after create' do
        @event.save!
        @event.update(start_time: Time.now - 1.second)
        @event.valid?.should == true
      end
    end
  end

  describe 'Methods' do
    describe '#facility' do
      it 'should return :admin facility' do
        @event.facility.should == @event.admin.facility
      end
    end
  end
end
