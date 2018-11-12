require 'rails_helper'

describe ApplicationController, type: :controller do
  before do
    # @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'Methods' do
    describe '#user_signed_in?' do
      it 'should return false if user is not signed in' do
        controller.user_signed_in?.should == false
      end

      it 'should return true if user is signed in' do
        sign_in create(:user)
        controller.user_signed_in?.should == true
      end
    end

    describe '#current_user' do
      it 'should return nil if user is not signed in' do
        controller.current_user.should == nil
      end

      it 'should return user, if user is signed in' do
        user = create(:user)
        sign_in(user)
        controller.current_user.should == user
      end
    end

    describe '#user_role' do
      # Actually in UserHelper, but relies on controller, methods, so testing here.
      it 'should return "guest" if user is not signed in' do
        controller.user_role.should == 'guest'
      end

      it 'should return user for user' do
        sign_in create(:user)
        controller.user_role.should == 'user'
      end

      it 'should return user for admin' do
        sign_in create(:admin)
        controller.user_role.should == 'admin'
      end

      it 'should return user for super_admin' do
        sign_in create(:super_admin)
        controller.user_role.should == 'super_admin'
      end
    end

    describe '#user_can?(role)' do
      # Also in UserHelper
      it 'should return false if user is not signed in' do
        controller.user_can?('user').should == false
      end

      it 'should return false if user.role is greater than or equal to role param' do
        sign_in create(:admin)
        controller.user_can?('user').should == true
        controller.user_can?('admin').should == true
        controller.user_can?('super_admin').should == false
      end

      specify 'super_admins can always' do
        sign_in create(:super_admin)
        controller.user_can?('user').should == true
        controller.user_can?('admin').should == true
        controller.user_can?('super_admin').should == true
      end
    end
  end
end
