module FeaturesHelper
  def login(user = create(:user))
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: ENV.fetch('PW')
    click_button 'Log in'
    user
  end
end
