require 'rails_helper'

describe FacilitiesController, type: :controller do
  before do
    @super_admin = create(:super_admin)
  end

  describe 'GET /facilities/new' do
    describe 'Permissions' do
      specify 'Only Super Admin can access' do
        sign_in @super_admin
        expect(get :new).not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in create(:admin)
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
  end

  describe 'POST /facilites' do
    describe 'Permissions' do
      specify 'Only Super Admin can access' do
        sign_in @super_admin
        expect(post :create, params: {facility: attributes_for(:facility)})
              .not_to redirect_to(root_url)
      end

      specify 'Lower Roles cannot' do
        sign_in create(:admin)
        expect(post :create, params: {facility: attributes_for(:facility)})
              .to redirect_to(root_url)
      end

      specify 'Non-signed in users cannot' do
        expect(post :create, params: {facility: attributes_for(:facility)})
              .to redirect_to(root_url)
      end
    end

    context 'Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should create a new Facility' do
        expect{ post :create, params: {facility: attributes_for(:facility)} }
              .to change{ Facility.count }.by(1)
      end

      it 'should redirect to the new Facility' do
        post :create, params: {facility: attributes_for(:facility)}
        response.should redirect_to Facility.last
      end

      it 'should accept address attributes' do
        facility_params = {facility: attributes_for(:facility)}
        facility_params[:facility][:address_attributes] = attributes_for(:address)

        expect{ post :create, params: facility_params }
              .to change { Address.count }.by(1)
      end
    end
  end # create


end
