require 'rails_helper'

describe Address, type: :model do
  before do
    @address = build(:address)
  end

  describe 'Associations' do
    it{ should belong_to(:has_address) }
  end

  describe 'Validations' do
    it{ should validate_inclusion_of(:state).in_array(Address::STATES.keys) }
    it{ should validate_presence_of :street }
    it{ should validate_presence_of :city }
    it{ should validate_presence_of :state }
    it{ should validate_presence_of :zip }
    it{ should validate_presence_of :timezone }
    it { should validate_inclusion_of(:timezone).in_array(Address.timezones) }
  end

  describe 'Idioms' do
    describe 'Geocoding' do
      it 'should geocode when saved' do
        expect{ @address.save! }
              .to change{ [@address.latitude, @address.longitude] }
              .from([nil, nil])
              .to([40.7143528, -74.0059731]) # Values based on Geocoder stub in spec/rails_helper
      end

      it 'should save :timezone when saved' do
        # testing info: https://github.com/panthomakos/timezone
        @address.timezone = nil

        puts @address.inspect

        expect{ @address.save! }.to change{ @address.timezone }
              .from(nil).to('US/Pacific')
      end

      it 'should not update :timezone if Timezone has been set' do
        @address.update(timezone: 'US/Pacific')
        expect{ @address.save! }.not_to change{ @address.timezone }
      end
    end
  end

  describe 'Methods' do
    describe '#to_s' do
      it 'should return Address values as single string' do
        @address.to_s.should == "#{@address.street}, #{@address.city}, #{@address.state} #{@address.zip}"
      end

      it 'should return a string with all extra Address values.' do
        @address.street2 = 'street2'
        @address.street3 = 'street3'
        @address.number = '#1'

        @address.to_s.should == "#{@address.street} #{@address.number}, #{@address.street2}, #{@address.street3}, #{@address.city}, #{@address.state} #{@address.zip}"

      end
    end

    describe '#full_state' do
      it 'should return the full state name' do
        @address.state = 'WA'
        @address.full_state.should == 'Washington'
      end
    end
  end
end
