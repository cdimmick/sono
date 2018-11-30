require 'rails_helper'

describe UsersController, type: :controller do
  before do
    @admin = create(:admin)
    @facility = @admin.facility
    @user = create(:user)
    @user.facilities << @facility
    @super_admin = create(:super_admin)
    @user_params = {user: attributes_for(:user)}
    @invalid_user_params = {user: attributes_for(:user, name: '')}
  end

  describe 'GET /users' do
    context 'As Guest' do
      it 'should reject' do
        expect(get :index).to redirect_to(root_url)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end
    end

    context 'As User' do
      before do
        sign_in @user
      end

      specify 'Lower Roles cannot' do
        expect(get :index).to redirect_to(root_url)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      specify 'Admin can access' do
        expect(get :index).not_to redirect_to(root_url)
      end

      it 'should render index template' do
        expect(get :index).to render_template(:index)
      end

      it 'should assign Users associted with this facility to @users' do
        other_user = create(:user) # To show that this is not included

        get :index
        assigns(:users).should == [@user]
      end

      it 'should assign Admins associted with this facility to @admins' do
        other_admin = create(:user)

        get :index
        assigns(:admins).should == [@admin]
      end

      it 'should assign admins associted with this facility to @admins' do
        other_admin = create(:admin)
        get :index
        assigns(:admins).should == [@admin]
       end

       it 'should NOT assign associates super_admins to @admin' do
         super_admin = create(:super_admin, facility_id: @admin.facility.id)
         get :index
         assigns(:admins).include?(super_admin).should == false
       end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      context 'Wihout acting_as set' do
        it 'should redirect to facilities' do
          expect(get :index).to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end

      context 'With acting_as set' do
        before do
          @super_admin.acting_as = @facility
        end

        it 'should render index template if super_admin has been an acts_as' do
          expect(get :index).to render_template(:index)
        end

        it 'should redirect to facilties_path if no Facility is set as Super Admins acting_as' do
          @super_admin.update(facility_id: nil)
          expect(get :index).to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end
    end
  end # Index

  describe 'POST /users' do
    context 'As Guest' do
      it 'should redirect user to root' do
        post :create, params: @user_params
        expect(response).to redirect_to(root_path)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end
    end

    context 'As admin' do
      before do
        sign_in @admin
      end

      it 'could create a user' do
        expect{ post :create, params: @user_params }
              .to change{ User.count }.by(1)
      end

      it 'could create an admin' do
        expect{ post :create, params: {user: attributes_for(:admin)} }
              .to change{ User.admins.count }.by(1)
      end

      it 'cannot create a super_admin' do
        expect{ post :create, params: {user: attributes_for(:super_admin)} }
              .not_to change{ User.count }
        expect(response).to redirect_to(users_path)
        flash[:alert].should == 'You cannot create that Role.'
      end

      it 'should redirect to /users if user is saved' do
        expect(post :create, params: @user_params).to redirect_to(users_url)
      end

      it 'should render new if params are not complete' do
        expect(post :create, params: @invalid_user_params).to render_template(:new)
      end

      it 'should send a welcome email' do
        allow(UsersMailer).to receive(:new_user).and_call_original
        post :create, params: @user_params
        expect(UsersMailer).to have_received(:new_user)
      end
    end

    context 'As Super Admin' do
      before do
        @facility = create(:facility)
        @super_admin = create(:super_admin, facility_id: @facility.id)
        sign_in @super_admin
      end

      it 'should redirect to facilties_path if no Facility is set as Super Admins acting_as' do
        @super_admin.update(facility_id: nil)
        expect(get :new).to redirect_to(facilities_path)
        flash[:alert].should == 'Please select a Facility to act as.'
      end

      it 'could create a user' do
        expect{ post :create, params: @user_params }.to change{ User.count }.by(1)
      end

      it 'could create an admin' do
        expect{ post :create, params: {user: attributes_for(:admin)} }
              .to change{ User.admins.count }.by(1)
      end

      it 'could create a super_admin' do
        expect{ post :create, params: {user: attributes_for(:super_admin)} }
              .to change{ User.super_admins.count }.by(1)
      end
    end
  end # Create

  describe 'DELETE /users/:id' do
    specify 'Guests cannot delete' do
      expect(delete :destroy, params: {id: @user.id}).to redirect_to(root_path)
      flash[:alert].should == "You must be an Admin to view that resource."
    end

    specify 'Users cannot delete' do
      sign_in @user
      expect(delete :destroy, params: {id: @user.id}).to redirect_to(root_path)
      flash[:alert].should == "You must be an Admin to view that resource."
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should remove the user from the facility' do
        expect{ delete :destroy, params: {id: @user.id} }
              .to change{ @user.reload.facilities.count }.by(-1)
      end

      it 'should not delete the User' do
        expect{ delete :destroy, params: {id: @user.id} }
              .not_to change{ User.exists?(@user.id) }
      end

      it 'should redirect_to users_path' do
        expect(delete :destroy, params: {id: @user.id}).to redirect_to(users_path)
        flash[:notice].should == 'User has been destroyed.'
      end

      it 'should not allow the Admin to remove a User
          that is not associated with their Facility' do
        new_user = create(:user)
        expect(delete :destroy, params: {id: new_user.id}).to redirect_to(root_path)
        flash[:alert].should == 'You must be acting as that Facility to destory that resource.'
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      context 'Without acting_as set' do
        it 'should redirect to facilities' do
          expect(delete :destroy, params: {id: @user.id}).to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end

      context 'With acting_as set' do
        before do
          @super_admin.acting_as = @facility
        end

        it 'should remove the user from the facility' do
          expect{ delete :destroy, params: {id: @user.id} }
                .to change{ @user.reload.facilities.count }.by(-1)
        end

        it 'should not delete the User' do
          expect{ delete :destroy, params: {id: @user.id} }
                .not_to change{ User.exists?(@user.id) }
        end

        it 'should redirect_to users_path' do
          expect(delete :destroy, params: {id: @user.id}).to redirect_to(users_path)
          flash[:notice].should == 'User has been destroyed.'
        end

        it 'should not allow the Admin to remove a User
            that is not associated with their Facility' do
          new_user = create(:user)
          expect(delete :destroy, params: {id: new_user.id}).to redirect_to(root_path)
          flash[:alert].should == 'You must be acting as that Facility to destory that resource.'
        end
      end
    end
  end
end
