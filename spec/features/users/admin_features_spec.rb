require 'rails_helper'

describe 'Admin Features', type: :feature do
  before do
    @admin = create(:admin)
    login @admin
  end

  describe 'Creating a User' do
    it 'should only allow Admin to create User and Admins' do
      visit '/users/new'
      options = page.find('#user_role').find_all('option').map{ |opt| opt.value }
      options.should == %w|user admin|
    end

    it 'should create a new User' do
      visit '/users/new'

      attrs = user_min

      fill_in 'user_phone', with: '1234567890'
      select 'User', from: 'user_role'
      expect{ click_button 'Create User' }.to change{ User.count }.by(1)

      user = User.last
      user.name.should == attrs[:name]
      user.email.should == attrs[:email]
      user.phone.should == '1234567890'
      user.role.should == 'user'
    end

    it "should assign admin's facility as one of User's facilities" do
      visit '/users/new'
      attrs = user_min
      select 'User', from: 'user_role'
      click_button 'Create User'
      user = User.last
      user.facilities.first.should == @admin.facility
    end

    it 'should redirect to users_path' do
      visit '/users/new'
      user_min
      click_button 'Create User'
      page.current_path.should == '/users'
    end
  end

  describe 'Creating an Admin' do
    it "should assign new Admin to @admin's facility" do
      visit '/users/new'
      user_min
      select 'Admin', from: 'user_role'
      click_button 'Create User'

      admin = User.last

      admin.role.should == 'admin'
      admin.facility.should == @admin.facility
    end
  end
end
