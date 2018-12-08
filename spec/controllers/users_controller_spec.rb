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
    allow(UsersMailer).to receive(:new_user).and_call_original
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

      it 'should not include not active Admins' do
        inactive_admin = create(:admin, facility_id: @admin.facility.id, active: false)
        get :index
        assigns(:admins).include?(inactive_admin).should == false

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

      it 'should redirect to /events/new if user is saved' do
        post :create, params: @user_params
        user = assigns[:user]
        expect(response).to redirect_to("#{new_event_path}?user_id=#{user.id}")
      end

      it 'should redirect to /users if Admin is saved' do
        expect(post :create, params: {user: attributes_for(:admin)})
              .to redirect_to(users_path)
      end

      it 'should render new if params are not complete' do
        expect(post :create, params: @invalid_user_params)
              .to render_template(:new)
      end

      it 'should send a welcome email' do
        post :create, params: @user_params
        expect(UsersMailer).to have_received(:new_user)
      end

      context 'User already exists' do
        before do
          @new_user_attributes = attributes_for(:user, email: @user.email)
        end

        specify 'if User already exist, DO NOT create a new user.' do
          expect{ post :create, params: {user: @new_user_attributes} }
                .not_to change{ User.users.count }
        end

        it 'should update existing user' do
          expect{ post :create, params: {user: @new_user_attributes} }
                .to change{ @user.reload.name }.to(@new_user_attributes[:name])
        end

        it 'should not change existing password' do
          expect{ post :create, params: {user: @new_user_attributes} }
                .not_to change{ @user.reload.password }
        end

        it 'should not send a new_user email' do
          post :create, params: {user: @new_user_attributes}
          expect(UsersMailer).to_not have_received(:new_user)
        end

        it "should associate user with @admin's facility" do
          @user.facilities.delete_all
          expect{ post :create, params: {user: @new_user_attributes} }
                .to change{ @user.reload.facilities.include?(@admin.facility) }
                .from(false).to(true)
        end
      end # User exists

      context 'Admin already exists' do
        before do
          @new_admin_attributes = attributes_for(:admin, email: @admin.email)
        end

        specify 'if User has the same email as admin, return uniqueness error' do
          post :create, params: {user: @new_admin_attributes}
          assigns[:user].errors[:email]
                 .include?('has already been taken').should == true
        end

        specify 'if User has the same email as admin, render :new' do
          post :create, params: {user: @new_admin_attributes}
          expect(response).to render_template(:new)
        end
      end

      context 'Super Admin already exists' do
        before do
          @new_super_admin_attributes = attributes_for(:super_admin, email: @super_admin.email)
        end

        specify 'if User has the same email as Super Admin, change nothing' do
          expect{ post :create, params: {user: @new_super_admin_attributes} }
                .not_to change{ @super_admin.reload.name }
        end

        specify 'if User has the same email as Super Admin, render :new' do
          post :create, params: {user: @new_super_admin_attributes}
          expect(response).to redirect_to(users_path)
          flash[:alert].should == 'You cannot create that Role.'
        end
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

      specify 'Admins cannot be destroyed' do
        other_admin = create(:admin, facility_id: @admin.facility.id)
        expect(delete :destroy, params: {id: other_admin.id})
              .to redirect_to(root_path)
        flash[:alert].should == 'You cannot destroy Admins.'
      end

      specify 'Super Admins cannot be destroyed' do
        other_admin = create(:super_admin, facility_id: @admin.facility.id)
        expect(delete :destroy, params: {id: other_admin.id})
              .to redirect_to(root_path)
        flash[:alert].should == 'You cannot destroy Super Admins.'
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
        flash[:alert].should == 'You must be a Super Admin to view that resource.'
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

        it 'should not allow the Super Admin to remove a User
            that is not associated with their acting_as Facility' do
          new_user = create(:user)
          expect(delete :destroy, params: {id: new_user.id})
                .to redirect_to(facilities_path)
          flash[:alert].should == 'You must selet a Facility to act as.'
        end

        specify 'Admins cannot be destroyed' do
          other_admin = create(:admin, facility_id: @admin.facility.id)
          expect(delete :destroy, params: {id: other_admin.id})
                .to redirect_to(root_path)
          flash[:alert].should == 'You cannot destroy Admins.'
        end

        specify 'Super Admins cannot be destroyed' do
          other_admin = create(:super_admin, facility_id: @admin.facility.id)
          expect(delete :destroy, params: {id: other_admin.id})
                .to redirect_to(root_path)
          flash[:alert].should == 'You cannot destroy Super Admins.'
        end
      end
    end
  end # Destroy

  describe 'DELETE /users/:id/deactivate' do
    describe 'As Admin' do
      before do
        sign_in @admin
      end

      describe 'Admins' do
        before do
          @other_admin = create(:admin, facility_id: @admin.facility.id)
        end

        specify 'Admins should not be destroyed' do
          expect{ delete :deactivate, params: {id: @other_admin.id} }
                .not_to change{ User.exists?(@other_admin.id) }
        end

        specify 'Admins should NOT be removed from facility' do
          expect{ delete :deactivate, params: {id: @other_admin.id} }
                .not_to change{ @other_admin.facility_id }
        end

        specify 'Admins should be set to inactive' do
          expect{ delete :deactivate, params: {id: @other_admin.id} }
                .to change{ @other_admin.reload.active }.from(true).to(false)
        end

        it 'should redirect to users_path' do
          expect(delete :deactivate, params: {id: @other_admin.id} )
                .to redirect_to(users_path)
          flash[:notice].should == "Admin has been deactivated."
        end

        specify 'Admins should NOT be able to Deactivate admins from other Facilities' do
          other_facility_admin = create(:admin)
          expect(delete :deactivate, params: {id: other_facility_admin.id})
                .to redirect_to(root_path)
          flash[:alert].should == 'You must be a Super Admin to view that resource.'
        end
      end

      describe 'Super Admins' do
        specify 'Admins cannot deactivate Super Admins' do
          delete :deactivate, params: {id: @super_admin.id}
          expect(response).to redirect_to(root_path)
          flash[:alert].should == 'You must be a Super Admin to view that resource.'
        end
      end
    end

    describe 'As Super Admin' do
      before do
        sign_in @super_admin
        @new_super_admin = create(:super_admin)
      end

      describe 'Admins' do
        specify 'Admins should not be destroyed' do
          expect{ delete :deactivate, params: {id: @admin.id} }
                .not_to change{ User.exists?(@admin.id) }
        end

        specify 'Admins should NOT be removed from facility' do
          expect{ delete :deactivate, params: {id: @admin.id} }
                .not_to change{ @admin.facility_id }
        end

        specify 'Admins should be set to inactive' do
          expect{ delete :deactivate, params: {id: @admin.id} }
                .to change{ @admin.reload.active }.from(true).to(false)
        end

        specify 'Super Admins should be able to Deactivate Admins from any Facility' do
          other_facility_admin = create(:admin)
          expect{ delete :deactivate, params: {id: other_facility_admin.id} }
                .to change{ other_facility_admin.reload.active }.from(true).to(false)
        end

        it 'should redirect to users_path' do
          delete :deactivate, params: {id: @admin.id}
          response.should redirect_to(users_path)
          flash[:notice].should == "Admin has been deactivated."
        end
      end

      describe 'Super Admins' do
        specify 'Super Admins should not be destroyed' do
          expect{ delete :deactivate, params: {id: @new_super_admin.id} }
                .not_to change{ User.exists?(@new_super_admin.id) }
        end

        it 'Should set Super Admin to inactive' do
          expect{ delete :deactivate, params: {id: @new_super_admin.id} }
                .to change{ @new_super_admin.reload.active }.from(true).to(false)
        end
      end
    end
  end # Deactivate

  describe 'GET /users/admins' do
    specify 'Guests cannot access' do
      expect(get :admins).to redirect_to(root_path)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    specify 'User cannot access' do
      sign_in @user
      expect(get :admins).to redirect_to(root_path)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    specify 'Admin cannot access' do
      sign_in @admin
      expect(get :admins).to redirect_to(root_path)
      flash[:alert].should == 'You must be a Super Admin to view that resource.'
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should render :admin' do
        expect(get :admins).to render_template(:admins)
      end

      it 'should assign all admins and super admins to @users' do
        get :admins
        assigns[:users].should == [@admin, @super_admin]
      end
    end
  end
end
