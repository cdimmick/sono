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
    start_time_input = find('#event_start_time')
    start_time_input.click
    find_all('.nextMonthDay').last.click
    find('body').click

    find('#event_user_id').find(:xpath, 'option[2]').select_option if has_css?('#event_user_id')

    attrs
  end

  def event_with_new_user_min
    event_attrs = event_min
    user_attrs = attributes_for(:user)
    find('#event_user_id').find(:option, '').select_option # Set user to blank.
    fill_in 'event_user_attributes_name', with: user_attrs[:name]
    fill_in 'event_user_attributes_email', with: user_attrs[:email]
    event_attrs[:user_attributes] = user_attrs
    event_attrs
  end
end
