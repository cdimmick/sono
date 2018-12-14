require 'rails_helper'

describe 'Events Admin Features' do
  before do
    @user = create(:user)
    @admin = create(:admin)
  end

  context 'As Admin' do
    before do
      login @admin
      visit "/events/new" 
    end

    describe 'Creating an Event' do
      it 'Should create an event' do
        attrs = event_min

        expect{ click_button 'Create Event' }.to change{ Event.count }.by(1)

        event = Event.last

      end
    end
  end
end
