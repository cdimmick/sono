require 'rails_helper'

describe 'Super Admin Features', type: :feature do
  before do
    @facility = create(:facility)
    @super_admin = create(:super_admin)
    login @super_admin
  end

  describe 'Creating a User' do
    context 'Without an acting_as set' do
      it 'should reject a SuperAdmin who has not selected a facility to act as' do
        visit '/users/new'
        page.current_path.should == facilities_path
        within '.alert' do
          page.should have_content 'Please select a Facility to act as.'
        end
      end
    end

    context 'With an acting_as set' do
      before do
        # This is necessary to set acting_as on Super Admin
        visit "/facilities/#{@facility.id}"
      end

      it 'should Super Admin to create User and Admins and Super Admins' do

        visit "/users/new"
        options = page.find('#user_role').find_all('option').map{ |opt| opt.value }
        options.should == %w|user admin super_admin|
      end

      it 'should create a user' do
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

      it 'should deliver a new user email' do
        allow(UsersMailer).to receive(:new_user).and_call_original

        visit '/users/new'
        user_min
        click_button 'Create User'
        expect(UsersMailer).to have_received(:new_user)
      end

      describe 'Creating an Admin' do
        it "should assign new Admin to @admin's facility" do
          visit '/users/new'
          user_min
          select 'Admin', from: 'user_role'
          click_button 'Create User'

          admin = User.last

          admin.role.should == 'admin'
          admin.facility.should == @super_admin.reload.acting_as
        end
      end

      describe 'Creating aa Super Admin' do
        it "should not assign a Facility to new @super_admin" do
          visit '/users/new'
          user_min
          select 'Super Admin', from: 'user_role'
          click_button 'Create User'

          super_admin = User.last

          super_admin.role.should == 'super_admin'
          super_admin.facility.should == nil
        end
      end
    end
  end
end
