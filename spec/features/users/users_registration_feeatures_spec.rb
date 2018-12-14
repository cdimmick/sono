require 'rails_helper'

describe 'User Registration Features', type: :feature do
  before do
    @admin = create(:facility)
  end

  it 'should create a user' do
    visit '/u/sign_up'

    attrs = user_sign_up_min

    expect{ click_button 'Sign up' }.to change{ User.count }.by(1)

    user = User.last
    user.name.should == attrs[:name]
    user.email.should == attrs[:email]
  end

  it 'should also save phone' do
    visit '/u/sign_up'
    user_sign_up_min

    phone = Faker::PhoneNumber.phone_number
    fill_in 'user_phone', with: phone

    click_button 'Sign up'

    User.last.phone.should == phone
  end

  it 'should not save if email already exists' do
    existing_user = create(:user)

    visit '/u/sign_up'

    user_sign_up_min

    fill_in 'user_email', with: existing_user.email

    expect{ click_button 'Sign up' }.not_to change{ User.count }

    within '#error_explanation' do
      page.should have_content "Email has already been taken"
    end
  end

  it 'Should save facility param passed as param :facility' do
    visit "/u/sign_up?key=#{@admin.id}"
    user_sign_up_min
    click_button 'Sign up'
    User.last.facilities.last.should == @admin.facility.id
  end
end
