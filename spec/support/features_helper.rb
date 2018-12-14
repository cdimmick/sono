module FeaturesHelper
  def login(user = create(:user))
    visit '/u/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: ENV.fetch('PW')
    click_button 'Sign in'
    user
  end

  def facility_min
    attrs = attributes_for(:facility)
    fill_in 'facility_name', with: attrs[:name]
    attrs
  end

  def user_min
    attrs = attributes_for(:user)
    fill_in 'user_name', with: attrs[:name]
    fill_in 'user_email', with: attrs[:email]
    attrs
  end

  def user_sign_up_min
    attrs = user_min
    fill_in 'user_password', with: ENV.fetch('PW')
    fill_in 'user_password_confirmation', with: ENV.fetch('PW')

    attrs
  end

  def event_min
    attrs = attributes_for(:event)

    fill_in 'event_start_time', with: attrs[:start_time]

    attrs
  end
end
