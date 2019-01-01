require 'rails_helper'

describe EventsController, type: :controller do
  before do
    @user = create(:user)
    @super_admin = create(:super_admin)
    @admin = create(:admin)
    @event = create(:event, admin_id: @admin.id, user_id: @user.id)
    @facility = @event.facility
    @facility.address = create(:address)
    @facility.save!
  end

  describe 'GET /events/download/:token' do
    specify 'If token matches @event.download_token, allow download' do
      pending 'Not sure how download will be provided'
      true.should == false
    end

    specify 'If token DOES NOT match @event.download_token, redirect' do
      get :download, params: {id: @event.id, token: 'x'}
      expect(response).to redirect_to root_path
      flash[:alert].should == 'You are not allowed to view that resource.'
    end
  end # Download

  describe 'POST /events/:id/invite' do
    before do
      allow(GuestsMailer).to receive(:invite).and_call_original
      @emails = 'test1@test.com, test2@test.com,test3@test.com'
    end

    specify 'Guests cannot access' do
      post :invite, params: {id: @event.id, emails: @emails}
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'As User' do
      before do
        sign_in @user
      end

      specify 'it should send an email to all email in params' do
        post :invite, params: {id: @event.id, emails: @emails}
        expect(GuestsMailer).to have_received(:invite).exactly(3).times
      end

      specify "Users should not be able to invite to other User's events" do
        @event.update(user_id: create(:user).id)
        post :invite, params: {id: @event.id, emails: @emails}
        expect(response).to redirect_to root_path
        flash[:alert].should == 'Only the Event User may view this resource.'
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      specify 'Only user can access' do
        post :invite, params: {id: @event.id, emails: @emails}
        expect(response).to redirect_to(root_path)
        flash[:alert].should == 'Only the Event User may view this resource.'
      end
    end
  end # Invite

  describe 'GET /events' do
    specify 'Guests cannot access' do
      expect(get :index).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    specify 'Users cannot access' do
      sign_in @user
      expect(get :index).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should render :index template' do
        expect(get :index).to render_template(:index)
      end

      it 'should assign all Facility Events' do
        admin2 = create(:admin, facility_id: @admin.facility.id)
        event2 = create(:event, admin_id: admin2.id)
        other_facility_event = create(:event)

        get :index
        assigns(:events).should == [@event, event2]
      end

      it 'should assign current_user facility to @facility' do
        get :index
        assigns(:facility).should == controller.current_user.facility
      end

      it 'should not assign past events' do
        old_event = create(:event, facility_id: @admin.facility.id)
        old_event.update(start_time: Time.now - 1.day)

        get :index
        assigns(:events).should == [@event]
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      context 'Without acting_as set' do
        it 'should redirect to facilities_path if no acting_as is set' do
          expect(get :index).to redirect_to(facilities_path)
          flash[:alert].should == "Please select a Facility to act as."
        end
      end

      context "With acting_as set" do
        before do
          @super_admin.update(facility_id: @admin.facility.id)
        end

        it 'should render :index' do
          expect(get :index).to render_template(:index)
        end


        it 'should assign all Facility Events' do
          admin2 = create(:admin, facility_id: @admin.facility.id)
          event2 = create(:event, admin_id: admin2.id)

          other_facility_event = create(:event)

          get :index
          assigns(:events).should == [@event, event2]
        end

        it 'should assign current_user facility to @facility' do
          get :index
          assigns(:facility).should == controller.current_user.facility
        end

        it 'should not assign past events' do
          old_event = create(:event, facility_id: @super_admin.facility.id)
          old_event.update(start_time: Time.now - 1.day)

          get :index
          assigns(:events).should == [@event]
        end
      end
    end
  end # end Index

  describe 'GET /events/:id' do
    describe 'As Guest' do
      it 'should set @require_password = true if Event has password' do
        @event.update(password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == true
      end

      specify '@password_required should be false if @event has no password' do
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end
    end

    describe 'As User' do
      before do
        sign_in @user
      end

      it "should set @require_password = false, if Event is user's, even if password is set" do
        @event.update(password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end

      it 'should set @require_password to true if Event is NOT user AND PW is set' do
        @event.update(password: ENV.fetch('PW'), user_id: create(:user).id)
        get :show, params: {id: @event.id}
        assigns[:password_required].should == true
      end

      specify '@password_required should be false if @event has no password' do
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end
    end

    describe 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should set @required_password to true if @admin is not associated with @event' do
        new_event = create(:event, password: ENV.fetch('PW'))
        get :show, params: {id: new_event.id}
        assigns[:password_required].should == true
      end

      it 'should set @require_password if @admin is @event.admin' do
        @event.update(password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end

      it 'should set @require_password to false if @admin is associated with @event' do
        new_admin = create(:admin, facility_id: @admin.facility.id)
        @event.update(admin_id: new_admin.id, password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end

      specify '@password_required should be false if @event has no password' do
        @event.update(password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end
    end

    describe 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should set @password_required to true even is password is set' do
        @event.update(password: ENV.fetch('PW'))
        get :show, params: {id: @event.id}
        assigns[:password_required].should == false
      end
    end
  end # end Show

  describe 'GET /events/new' do
    specify 'Guests cannot access' do
      expect(get :new).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    specify 'Users cannot access' do
      sign_in @user
      expect(get :new).to redirect_to(root_path)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should render :new' do
        expect(get :new).to render_template(:new)
      end

      it "should assign @admin's facility to @facility" do
        get :new
        assigns(:facility).should == @admin.facility
      end

      it 'should assign a new Event to @event' do
        get :new
        assigns(:event).should be_a(Event)
        assigns(:event).should be_new_record
      end

      it 'should assin @event.user if user_id is provided as param' do
        get :new, params: {user_id: @user.id}
        assigns(:event).user_id.should == @user.id
      end

      it 'should assing nil to @event.user_id if user_id is NOT provided as param' do
        get :new
        assigns(:event).user_id.should == nil
      end

      it 'should assign all Facility users to @users' do
        facility_user = create(:user)
        facility_user.facilities << @admin.facility

        get :new
        assigns(:users).should == [facility_user]
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      context 'Without acting_as set' do
        it 'should redirect to facilities.' do
          expect(get :new).to redirect_to(facilities_path)
          flash[:alert].should == "Please select a Facility to act as."
        end
      end

      context 'With acting_as set' do
        before do
          @super_admin.update(facility_id: @admin.facility.id)
        end

        it 'should render :new' do
          expect(get :new).to render_template(:new)
        end

        it "should assign @super_admin's Facilty to @facility" do
          get :new
          assigns(:facility).should == @super_admin.facility
        end

        it 'should assign a new Event to @event' do
          get :new
          assigns(:event).should be_a(Event)
          assigns(:event).should be_new_record
        end

        it 'should assin @event.user if user_id is provided as param' do
          get :new, params: {user_id: @user.id}
          assigns(:event).user_id.should == @user.id
        end

        it 'should assing nil to @event.user_id if user_id is NOT provided as param' do
          get :new
          assigns(:event).user_id.should == nil
        end

        it 'should assign all Facility users to @users' do
          facility_user = create(:user)
          facility_user.facilities << @admin.facility

          get :new
          assigns(:users).should == [facility_user]
        end
      end
    end
  end # New

  describe 'POST /events' do
    before do
      allow(UsersMailer).to receive(:new_event).and_call_original
      allow(FacilitiesMailer).to receive(:new_event).and_call_original

      @event_params = {
        event: attributes_for(
          :event,
          user_id: @user.id,
          facility_id: @admin.facility.id)
      }
    end

    specify 'Guests cannot create' do
      expect(post :create, params: @event_params)
            .to redirect_to(new_user_session_path)
      flash[:alert].should == 'You need to sign in or sign up before continuing.'
    end

    context 'As User' do
      before do
        sign_in @user
      end

      it 'should be able to create an Event' do
        expect{ post :create, params: @event_params }.to change{ Event.count }.by(1)

        event = assigns[:event]

        event.local_time.strftime('%FT%R').should ==
              Time.parse(@event_params[:event][:start_time]).strftime('%FT%R')
        event.user = @user
      end

      it 'should save password' do
        @event_params[:event][:password] = ENV.fetch('PW')
        post :create, params: @event_params
        assigns[:event].password.should == ENV.fetch('PW')
      end

      it 'should redirect to the new Event' do
        expect(post :create, params: @event_params)
              .to redirect_to("/events/#{assigns(:event).id}")
        flash[:notice].should == 'Event was successfully created.'
      end

      it 'should send an email to user' do
        post :create, params: @event_params
        expect(UsersMailer).to have_received(:new_event).with(assigns[:event].id)
      end

      it 'should send an email to Facility' do
        post :create, params: @event_params
        expect(FacilitiesMailer).to have_received(:new_event).with(assigns[:event].id)
      end

      context 'Failure' do
        before do
          @event_params[:event][:user_id] = nil
        end
        it 'should not create a New Event if params are missing' do
          expect{ post :create, params: @event_params }.not_to change{ Event.count }
        end

        it 'should render users/show' do
          expect(post :create, params: @event_params).to render_template('users/show')
        end
      end
    end

    context 'Admin' do
      before do
        sign_in @admin
      end

      it 'should be able to create an Event' do
        expect{ post :create, params: @event_params }
              .to change{ Event.count }.by(1)

        event = Event.last

        event.local_time.strftime('%FT%R').should ==
              Time.parse(@event_params[:event][:start_time]).strftime('%FT%R')
        event.user = @user
        event.admin = @admin
      end

      it 'should redirect to the new Event' do
        expect(post :create, params: @event_params)
              .to redirect_to("/events/#{assigns(:event).id}")
        flash[:notice].should == 'Event was successfully created.'
      end

      it 'should send an email to user' do
        post :create, params: @event_params
        expect(UsersMailer).to have_received(:new_event).with(assigns[:event].id)
      end

      it 'should not create a New Event if params are missing' do
        @event_params[:event][:user_id] = nil
        expect{ post :create, params: @event_params }
              .not_to change{ Event.count }
        expect(response).to render_template(:new)
      end

      describe 'Failure' do
        it 'should assign all Facility users to @users' do
          facility_user = create(:user)
          facility_user.facilities << @admin.facility
          @event_params[:event][:start_time] = nil
          post :create, params: @event_params
          assigns(:users).should == [facility_user]
        end
      end
    end

    context 'As Super Admin' do
      before do
        sign_in  @super_admin
      end

      context 'Without acting_as set' do
        it 'should redirect to users' do
          expect(post :create, params: @event_params)
                .to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end

      context 'With acting_as set' do
        before do
          @super_admin.update(facility_id: @admin.facility.id)
        end

        it 'should be able to create an Event' do
          expect{ post :create, params: @event_params }
                .to change{ Event.count }.by(1)

          event = Event.last
          event.user = @user
          event.admin = @super_admin
        end

        it 'should redirect to the new Event' do
          expect(post :create, params: @event_params)
               .to redirect_to("/events/#{assigns(:event).id}")
          flash[:notice].should == 'Event was successfully created.'
        end

        it 'should send an email to user' do
          post :create, params: @event_params
          expect(UsersMailer).to have_received(:new_event).with(assigns[:event].id)
        end

        it 'should send an email to Facility' do
          post :create, params: @event_params
          expect(FacilitiesMailer).to have_received(:new_event).with(assigns[:event].id)
        end

        it 'should not create a New Event if params are missing' do
          @event_params[:event][:user_id] = nil

          expect{ post :create, params: @event_params }
                .not_to change{ Event.count }
          expect(response).to render_template(:new)
        end
      end
    end
  end # Create

  describe 'PUT /users/:id' do
    before do
      allow(UsersMailer).to receive(:changed_event).and_call_original
      allow(FacilitiesMailer).to receive(:changed_event).and_call_original
      @event_params = {
        id: @event.id,
        event: attributes_for(:event, start_time: @event.start_time + 1.day)
      }
    end

    specify 'Guests cannot update' do
      expect(put :update, params: {id: @event.id})
            .to redirect_to(new_user_session_path)
      flash[:alert].should == 'You need to sign in or sign up before continuing.'
    end

    context 'As User' do
      before do
        @event.update(user_id: @user.id)
        sign_in @user
      end

      it "should not allow user to edit another user's Event" do
        new_event = create(:event)
        @event_params[:id] = new_event.id
        expect(put :update, params: @event_params).to redirect_to(root_path)
        flash[:alert].should == 'You must be an Admin to view that resource.'
      end

      it 'should update @event' do
        @time = @event.local_time

        expect{ put :update, params: @event_params }
              .to change{ @event.reload.local_time.strftime('%FT%T') }
              .from(@time.strftime('%FT%T'))
              .to(@event_params[:event][:start_time].strftime('%FT%T'))
      end

      context 'Success' do
        before do
          put :update, params: @event_params
        end

        it 'should assign @event' do
          assigns[:event].should == @event
        end

        it 'should redirect to /events' do
          expect(response).to redirect_to(user_path(@user))
          flash[:notice].should == 'Event was updated.'
        end

        it 'should send an email to @event.user' do
          expect(UsersMailer).to have_received(:changed_event)
                .with(assigns[:event].id)
        end

        it 'should send an email to @event.facility' do
          expect(FacilitiesMailer).to have_received(:changed_event)
                .with(assigns[:event].id)
        end
      end

      context 'Failure' do
        before do
          @event_params[:event][:start_time] = nil
        end

        it 'should render :edit' do
          put :update, params: @event_params
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should update @event' do
        @time = @event.local_time

        expect{ put :update, params: @event_params }
              .to change{ @event.reload.local_time.strftime('%FT%T') }
              .from(@time.strftime('%FT%T'))
              .to(@event_params[:event][:start_time].strftime('%FT%T'))
      end

      context 'Success' do
        before do
          put :update, params: @event_params
        end

        it 'should assign @event' do
          assigns[:event].should == @event
        end

        it 'should redirect to /event/:id' do
          expect(response).to redirect_to(event_path(assigns[:event]))
          flash[:notice].should == 'Event was updated.'
        end

        it 'should send an email to @event.user' do
          expect(UsersMailer).to have_received(:changed_event)
                .with(assigns[:event].id)
        end

        it 'should send an email to Facility' do
          expect(FacilitiesMailer).to have_received(:changed_event).with(assigns[:event].id)
        end
      end

      context 'Failure' do
        before do
          @event_params[:event][:start_time] = nil
          put :update, params: @event_params
        end

        it 'should render :edit' do
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      it 'should redirect to /facilities if :acting_as is not set' do
        put :update, params: @event_params
        expect(response).to redirect_to(facilities_path)
        flash[:alert].should == 'Please select a Facility to act as.'
      end
    end
  end

  describe 'GET /users/:id/edit' do
    specify 'Guests cannot edit' do
      expect(get :edit, params: {id: @event.id}).to redirect_to(new_user_session_path)
      flash[:alert].should == 'You need to sign in or sign up before continuing.'
    end

    context 'As User' do
      before do
        @event.update(user_id: @user.id)
        sign_in @user
      end

      it 'should render :edit' do
        expect(get :edit, params: {id: @event.id})
              .to render_template(:edit)
      end

      it 'should assign @event' do
        get :edit, params: {id: @event.id}
        assigns[:event].should == @event
      end

      it "should prevent User from accessing edit for an event that isn't theirs" do
        new_event = create(:event)
        expect(get :edit, params: {id: new_event.id}).to redirect_to(root_path)
        flash[:alert].should == 'You are not allowed to edit that resource.'
      end
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      it 'should render :edit' do
        expect(get :edit, params: {id: @event.id})
              .to render_template(:edit)
      end

      it 'should assign @event' do
        get :edit, params: {id: @event.id}
        assigns[:event].should == @event
      end

      it 'should redirect to root if admin.facility does not equal event.facility' do
        new_admin = create(:admin)
        @event.update(admin_id: new_admin.id)
        expect(get :edit, params: {id: @event.id}).to redirect_to(root_path)
        flash[:alert].should == 'You are not allowed to edit that resource.'
      end
    end

    context 'As Super Admin' do
      before do
        sign_in @super_admin
      end

      context 'Without :acting_as set' do
        it 'should redirect to /facilities' do
          expect(get :edit, params: {id: @event.id})
                .to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end

      context 'With :acting_as set' do
        before do
          @super_admin.acting_as = @event.facility
        end

        it 'should render :edit' do
          expect(get :edit, params: {id: @event.id})
          .to render_template(:edit)
        end

        it 'should assign @event' do
          get :edit, params: {id: @event.id}
          assigns[:event].should == @event
        end
      end
    end
  end # Edit

  describe 'DELETE /users/:id' do
    specify 'Guests cannot delete' do
      expect(delete :destroy, params: {id: @event.id}).to redirect_to(root_path)
      flash[:alert].should == "You must be an Admin to view that resource."
    end

    specify 'Users cannot delete' do
      sign_in @user
      expect(delete :destroy, params: {id: @event.id}).to redirect_to(root_path)
      flash[:alert].should == "You must be an Admin to view that resource."
    end

    context 'As Admin' do
      before do
        sign_in @admin
      end

      specify 'Admin should be able to delete Events they created' do
        expect{ delete :destroy, params: {id: @event.id} }
              .to change{ Event.exists?(@event.id) }.from(true).to(false)
      end

      specify 'Admin should be able to destroy Events from their Facility' do
        other_admin = create(:admin, facility_id: @admin.facility.id)
        @event.admin = other_admin
        @event.save!

        expect{ delete :destroy, params: {id: @event.id} }
              .to change{ Event.exists?(@event.id) }.from(true).to(false)
      end

      it 'should render :index' do
        expect(delete :destroy, params: {id: @event.id}).to redirect_to(events_path)
        flash[:notice].should == 'Event was successfully destroyed.'
      end

      specify 'Admin SHOULD NOT be able to delete events form other facilities' do
        new_event = create(:event)
        expect{ delete :destroy, params: {id: new_event.id} }
              .not_to change{ Event.exists?(new_event.id) }
        response.should redirect_to(root_url)
        flash[:alert].should == 'You must be a Super Admin to view that resource.'
      end
    end
  end # Destroy
end
