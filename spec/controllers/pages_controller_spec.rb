require 'rails_helper'

describe PagesController, type: :controller do
  before do
    @user = create(:user)
    @admin = create(:admin)
    @super_admin = create(:super_admin)
  end

  describe 'Get /pages/router' do
    specify 'Guests should redirect_to home' do
      expect(get :router).to redirect_to(home_path)
    end

    specify 'Users should' do
      sign_in @user
      expect(get :router).to redirect_to(users_path(@user))
    end

    specify 'Admin should redirect to facility' do
      sign_in @admin
      expect(get :router).to redirect_to(facility_path(@admin.facility))
    end

    specify 'Super Admin should redirect to facilities' do
      sign_in @super_admin
      expect(get :router).to redirect_to(facilities_path)
    end
  end # end Router
end
