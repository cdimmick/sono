require 'rails_helper'

describe 'Facility Features', type: :feature do
  before do
    @super_admin = create(:super_admin)
  end

  describe 'Creating a Facility' do
    specify 'Admins or lower cannot Create a Facility' do
      login create(:admin)
      visit '/facilities/new'
      page.current_path.should == '/'
    end

    context 'As Super Admin' do
      before do
        login @super_admin
        visit '/facilities/new'
      end

      specify '@super_admin should be able to create user' do
        name = Faker::Company.name
        phone = Faker::PhoneNumber.phone_number
        street = Faker::Address.street_address
        street2 = Faker::Address.street_address
        city = Faker::Address.city
        state = Address::STATES.keys.sample
        zip = Faker::Address.zip

        fill_in 'facility_name', with: name
        fill_in 'facility_phone', with: phone
        fill_in 'facility_address_attributes_street', with: street
        fill_in 'facility_address_attributes_street2', with: street2
        fill_in 'facility_address_attributes_city', with: city
        select Address::STATES[state], from: 'facility_address_attributes_state'
        fill_in 'facility_address_attributes_zip', with: zip

        expect{ click_button 'Create' }
              .to change{ [Facility.count, Address.count] }
              .by([1, 1])

        facility = Facility.last

        facility.name.should == name
        facility.phone.should == phone

        address = facility.address

        address.street.should == street
        address.street2.should == street2
        address.city.should == city
        address.state.should == state
        address.zip.should == zip

        page.current_path.should == "/facilities/#{facility.to_param}"
      end
    end
  end

  describe 'Editing a Facility' do
    before do
      @facility = create(:complete_facility)
    end

    specify 'Admins or lower cannot Create a Facility' do
      login create(:admin)
      visit "/facilities/#{@facility.to_param}/edit"
      page.current_path.should == '/'
    end

    context 'As Super Admin' do
      before do
        login @super_admin
        visit "/facilities/#{@facility.to_param}/edit"
      end

      specify '@super_admin should be able to create user' do
        name = Faker::Company.name
        phone = Faker::PhoneNumber.phone_number
        street = Faker::Address.street_address
        street2 = Faker::Address.street_address
        city = Faker::Address.city
        state = Address::STATES.keys.sample
        zip = Faker::Address.zip

        fill_in 'facility_name', with: name
        fill_in 'facility_phone', with: phone
        fill_in 'facility_address_attributes_street', with: street
        fill_in 'facility_address_attributes_street2', with: street2
        fill_in 'facility_address_attributes_city', with: city
        select Address::STATES[state], from: 'facility_address_attributes_state'
        fill_in 'facility_address_attributes_zip', with: zip

        click_button 'Update'

        @facility.reload
        @facility.name.should == name
        @facility.phone.should == phone

        address = @facility.address

        address.street.should == street
        address.street2.should == street2
        address.city.should == city
        address.state.should == state
        address.zip.should == zip

        page.current_path.should == "/facilities/#{@facility.to_param}"
      end
    end
  end
end