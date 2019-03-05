require 'rails_helper'

describe 'Edit features', type: :feature do
  before do
    @admin = create(:admin)
    @facility = @admin.facility
    @user = create(:user)
    @user.facilities << @facility
    @event = create(:event, admin_id: @admin.id, user_id: @user.id)
  end

  context 'As User' do
    before do
      login @user
    end

    it 'should show local_time as start_time' do
      visit "/events/#{@event.to_param}/edit"
      time_in_view = Time.parse(find('#event_start_time').value).strftime('%FT')
      time_in_view.should == @event.local_time.strftime('%FT')
    end

    it 'should all User to update record' do
      time_string = '2000-01-01T20:00'
      visit "/events/#{@event.to_param}/edit"
      fill_in 'event_start_time', with: time_string
      click_button 'Update Event'
      @event.reload.local_time.strftime('%FT%R').should == time_string
    end
  end

  context 'As Admin' do
  end
end
