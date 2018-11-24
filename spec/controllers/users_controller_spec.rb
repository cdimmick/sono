require 'rails_helper'

describe UsersController, type: :controller do
  before do
    @admin = create(:admin)
    @facility = create(:facility)
    @admin.update(facility_id: @facility.id)
  end

  describe 'GET /facilities/:id/users' do
    describe 'Permissions' do
      specify 'Admin can access' do
        sign_in @admin
        expect(get :index, params: {id: @facility.id})
              .not_to redirect_to(root_url)
      end

      specify 'Super Admins can access' do
        sign_in create(:super_admin)
        expect(get :index, params: {id: @facility.id})
              .not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in create(:user)
        expect(get :index, params: {id: @facility.id})
              .to redirect_to(root_url)
      end

      specify 'Non-signed in users cannot' do
        expect(get :index, params: {id: @facility.id})
              .to redirect_to(root_url)
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should assign facility to @facility' do
        get :index, params: {id: @facility.id}
        assigns(:facility).should == @facility
      end

      it 'should render index template' do
        expect(get :index, params: {id: @facility.id})
              .to render_template(:index)
      end

      it 'should assign users associted with this facility to @users' do
        user = create(:user)
        user.facilities << @facility

        other_user = create(:user)

        get :index, params: {id: @facility.id}
        assigns(:users).should == [user]
      end

      it 'should assign admins associted with this facility to @admins' do
        other_admin = create(:admin)

        get :index, params: {id: @facility.id}
        assigns(:admins).should == [@admin] 
      end
    end
  end # Index
end
