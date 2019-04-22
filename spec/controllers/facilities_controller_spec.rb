require 'rails_helper'

describe FacilitiesController, type: :controller do
  before do
    @super_admin = create(:super_admin)
    @admin = create(:admin)
    @user = create(:user)
    @facility = create(:facility)

    @facility_params = {facility: attributes_for(:facility)}
    @facility_params[:facility][:address_attributes] = attributes_for(:address)
  end

  describe 'GET /facilities' do
    describe 'Permissions' do
      specify 'Only Super Admin can access' do
        sign_in @super_admin
        expect(get :index).not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in create(:admin)
        expect(get :index).to redirect_to(root_url)
      end

      specify 'Non-signed in users cannot' do
        expect(get :index).to redirect_to(root_url)
      end
    end

    context 'As SuperAdmin' do
      before do
        sign_in @super_admin
      end

      it 'should assign all facilities to @facilities' do
        get :index
        facilities = assigns(:facilities)
        assigns(:facilities).should == [@admin.facility, @facility]
      end

      it 'should render index template' do
        expect(get :index).to render_template(:index)
      end
    end
  end # end Index

  describe 'GET /facilities/:id' do
    context 'As Guest' do
      it 'should redirect to root' do
        get :show, params: {id: @facility.id}
        expect(response).to redirect_to(root_path)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end
    end

    context 'As User' do
      before do
        sign_in @user
      end

      it 'should redirect to root' do
        get :show, params: {id: @facility.id}
        expect(response).to redirect_to(root_path)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should render the show template' do
        expect(get :show, params: {id: @admin.facility.id})
              .to render_template(:show)
      end

      it 'should redirect to root if @admin is not Admin of this facility' do
        other_facility = create(:facility)
        get :show, params: {id: other_facility.id}
        expect(response).to redirect_to(root_path)
        flash[:alert].should == 'You must be a Super Admin to view that resource.'
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should render show template' do
        expect(get :show, params: {id: @facility.id}).to render_template(:show)
      end

      it 'should set facilities on SuperAdmin' do
        expect{ get :show, params: {id: @facility.id} }
              .to change{ @super_admin.reload.facility }.from(nil).to(@facility)
      end
    end
  end

  describe 'GET /facilities/new' do
    describe 'Permissions' do
      specify 'Only Super Admin can access' do
        sign_in @super_admin
        expect(get :new).not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in @admin
        expect(get :new).to redirect_to(root_url)
      end

      specify 'Non-signed in users cannot' do
        expect(get :new).to redirect_to(root_url)
      end
    end

    context 'As SuperAdmin' do
      before do
        sign_in @super_admin
      end

      it 'should render the new template' do
        expect(get :new).to render_template(:new)
      end
    end
  end # New

  describe 'POST /facilites' do
    describe 'Permissions' do
      specify 'Only Super Admin can access' do
        sign_in @super_admin
        expect(post :create, params: @facility_params)
              .not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in @admin
        expect(post :create, params: @facility_params)
              .to redirect_to(root_url)
      end

      specify 'Non-signed in users cannot' do
        expect(post :create, params: @facility_params)
              .to redirect_to(root_url)
      end
    end

    context 'Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should create a new Facility' do
        expect{ post :create, params: @facility_params }
              .to change{ Facility.count }.by(1)
      end

      it 'should redirect to the new Facility' do
        post :create, params: @facility_params
        response.should redirect_to Facility.last
      end

      it 'should accept address attributes' do
        expect{ post :create, params: @facility_params }
              .to change { Address.count }.by(1)
      end
    end
  end # create

  describe 'Edit' do
    specify 'Guests cannot edit' do
      expect(get :edit, params: {id: @facility.id}).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    specify 'User cannot edit' do
      sign_in create(:user)
      expect(get :edit, params: {id: @facility.id}).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should render edit' do
        expect(get :edit, params: {id: @admin.facility.id})
              .to render_template(:edit)
      end

      it 'should NOT allow adming to Edit if Admin does not belong to Facility' do
        expect(get :edit, params: {id: @facility.id}).to redirect_to(root_url)
        flash[:alert].should == 'You must be a Super Admin to view that resource.'
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should render edit for any Facility' do
        expect(get :edit, params: {id: @facility.id})
              .to render_template(:edit)
      end
    end
  end # Edit

  describe 'Update' do
  end

  describe 'Destroy' do
    specify 'Guest cannot destory' do
      expect(delete :destroy, params: {id: @facility.id}).to redirect_to(root_url)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    specify 'Users cannot destory' do
      sign_in @user
      expect(delete :destroy, params: {id: @facility.id}).to redirect_to(root_url)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    specify 'Admins cannot destory' do
      sign_in @admin
      expect(delete :destroy, params: {id: @admin.facility.id}).to redirect_to(root_url)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      specify 'Super Admins can Destroy' do
        expect{ delete :destroy, params: {id: @facility.id} }
              .to change{ Facility.exists?(@facility.id) }.from(true).to(false)
      end

      it 'should redirect_to Facilities' do
        expect(delete :destroy, params: {id: @facility.id})
              .to redirect_to(facilities_url)
      end
    end
  end # Destroy
end
