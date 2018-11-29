require 'rails_helper'

describe EventsController, type: :controller do
  before do
    @user = create(:user)
    @super_admin = create(:super_admin)
    @admin = create(:admin)
    @event = create(:event, admin_id: @admin.id)
  end

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

  describe 'New' do
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

  describe 'POST /users' do
    specify 'Guests cannot create' do
      expect(post :create, params: {event: attributes_for(:event)})
            .to redirect_to(root_url)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    specify 'Users cannot create' do
      sign_in @user

      expect(post :create, params: {event: attributes_for(:event)})
            .to redirect_to(root_url)
      flash[:alert].should == 'You must be an Admin to view that resource.'
    end

    context 'Admin' do
      before do
        sign_in @admin
      end

      it 'should be able to create an Event' do
        attrs = attributes_for(:event, user_id: @user.id)
        expect{ post :create, params: {event: attrs} }
              .to change{ Event.count }.by(1)

        event = Event.last

        # event.start_time.strftime('%D%r').should == attrs[:start_time].strftime('%D%r')
        event.user = @user
        event.admin = @admin
      end

      it 'should redirect to the new Event' do
        expect(post :create, params: {event: attributes_for(:event, user_id: @user.id)})
             .to redirect_to("/events/#{assigns(:event).id}")
        flash[:notice].should == 'Event was successfully created.'
      end

      it 'should send an email to user' do
        allow(UsersMailer).to receive(:new_event).and_call_original
        post :create, params: {event: attributes_for(:event, user_id: @user.id)}
        expect(UsersMailer).to have_received(:new_event)
      end

      it 'should not create a New Event if params are missing' do
        expect{ post :create, params: {event: attributes_for(:event)} } # user_id not provided
              .not_to change{ Event.count }
        expect(response).to render_template(:new)
      end
    end

    context 'As Super Admin' do
      before do
        sign_in  @super_admin
      end

      context 'Without acting_as set' do
        it 'should redirect to users' do
          expect(post :create, params: {event: attributes_for(:event)})
                .to redirect_to(facilities_path)
          flash[:alert].should == 'Please select a Facility to act as.'
        end
      end

      context 'With acting_as set' do
        before do
          @super_admin.update(facility_id: @admin.facility.id)
        end
        it 'should be able to create an Event' do
          attrs = attributes_for(:event, user_id: @user.id)
          expect{ post :create, params: {event: attrs} }
                .to change{ Event.count }.by(1)

          event = Event.last

          # event.start_time.strftime('%D%r').should == attrs[:start_time].strftime('%D%r')
          event.user = @user
          event.admin = @super_admin
        end

        it 'should redirect to the new Event' do
          expect(post :create, params: {event: attributes_for(:event, user_id: @user.id)})
               .to redirect_to("/events/#{assigns(:event).id}")
          flash[:notice].should == 'Event was successfully created.'
        end

        it 'should send an email to user' do
          allow(UsersMailer).to receive(:new_event).and_call_original
          post :create, params: {event: attributes_for(:event, user_id: @user.id)}
          expect(UsersMailer).to have_received(:new_event)
        end
      end
    end
  end # Create

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
