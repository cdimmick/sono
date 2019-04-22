require 'rails_helper'

describe 'Create Features', type: :feature do
  before do
    @admin = create(:admin)
    @facility = @admin.facility
    @user = create(:user)
    @user.facilities << @facility
  end

  context 'As User' do
    before do
      login @user
    end

    it 'should not show New User fields' do
      true.should == false
    end

    it 'should create a user' do
      visit "/users/#{@user.id}"

      attrs = event_min

      expect{ click_button 'Create Event' }.to change{ Event.count }.by(1)

      event = Event.last

      event.user.should == @user
      event.facility.should == @facility
    end

    it 'should allow user to select different facilties' do
      new_facility = create(:facility)
      new_facility.admins << create(:admin)
      @user.facilities << new_facility

      visit "/users/#{@user.id}"

      event_min

      find('#event_facility_id').find(:option, new_facility.name).select_option

      click_button 'Create Event'

      Event.last.facility.should == new_facility
    end

    it 'should allow user to set password' do
      visit "/users/#{@user.id}"
      event_min
      fill_in 'event_password', with: ENV.fetch('PW')
      click_button 'Create Event'
      Event.last.password.should == ENV.fetch('PW')
    end

    it 'should save at the time submitted in local time' do
      visit "/users/#{@user.id}"
      attrs = event_min
      click_button 'Create Event'

      event = Event.last
      event.local_time.strftime('%FT%R').should ==
            Time.parse(attrs[:start_time]).strftime('%FT%R')
    end
  end

  context 'As Admin' do
    before do
      login @admin
    end

    describe 'Creating an Event' do
      it 'Should create an event' do
        visit "/events/new"

        attrs = event_min

        option = find('#event_user_id').find_all('option').last
        user_name = option.text

        find('#event_user_id').find(:option, user_name).select_option

        expect{ click_button 'Create Event' }.to change{ Event.count }.by(1)

        event = Event.last

        event.user.name.should == user_name
      end
    end

    describe 'Creating an Event and a new User' do
      true.should == false
    end
  end
end
