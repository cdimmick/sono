require 'rails_helper'

describe 'User Features', type: :feature do
  before do
    @user = create(:user)
  end

  it 'should be able to log in' do
    login @user
    page.current_path.should == "/users/#{@user.to_param}"
  end

  it 'should fail to log in if user is not :active' do
    @user.update(active: false)
    login @user
    page.current_path.should == '/u/sign_in' 
  end

  it 'should add a new facility to user, if facility_id is provided as param' do
    facility = create(:facility)

    visit "/u/sign_in?facility_id=#{facility.id}"
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: ENV.fetch('PW')
    click_button 'Sign in'

    @user.reload.facilities.last.should == facility
  end

  it 'should not add a facility, if no facility_id is provided as param' do
    expect{ login @user }.not_to change{ @user.facilities.count }
  end
end
