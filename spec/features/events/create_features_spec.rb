require 'rails_helper'

describe 'Create Features', type: :feature, js: true do
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
      visit "/users/#{@user.id}"
      has_css?('#new_user_fields').should == false
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
      pending 'Because of issues with JavaScript and flatpicker, the last day on
               the monthly calendar is selected for start_time, so this script
               breaks. Saving as local time is tested in events_controller_spec.'
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
      it 'It should create new user' do
        visit '/events/new'
        attrs = event_with_new_user_min
        expect{ click_button 'Create Event' }.to change{ User.count }.by(1)
        user = User.last
        user.name.should == attrs[:user_attributes][:name]
        user.email.should == attrs[:user_attributes][:email]
      end

      it 'should send new_user mail with login info' do
        allow(UsersMailer).to receive(:new_user).and_call_original
        expect(UsersMailer).to receive(:new_user)
        visit '/events/new'
        event_with_new_user_min
        click_button 'Create Event'
      end
    end
  end
end
