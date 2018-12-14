# require 'rails_helper'
#
# describe SignUpsController, type: :controller do
#   before do
#     @admin = create(:admin)
#
#     @sign_up_params = {
#       id: @admin.id,
#       sign_up: {
#         name: Faker::Name.name,
#         phone: Faker::PhoneNumber.phone_number,
#         email: Faker::Internet.email,
#         start_time: Time.now + 1.day,
#         password: ENV.fetch('PW'),
#         password_confirmation: ENV.fetch('PW')
#       }
#     }
#   end
#
#   describe 'GET /facilities/:id/sign_ups/new' do
#     specify 'Users cannot access' do
#       sign_in create(:user)
#       expect(get :new, params: {id: @admin.id}).to redirect_to(root_path)
#       flash[:alert].should == "You must sign out to view that resource."
#     end
#
#     specify 'Admins cannot access' do
#       sign_in create(:admin)
#       expect(get :new, params: {id: @admin.id}).to redirect_to(root_path)
#       flash[:alert].should == "You must sign out to view that resource."
#     end
#
#     specify 'Super Admins cannot access' do
#       sign_in create(:super_admin)
#       expect(get :new, params: {id: @admin.id}).to redirect_to(root_path)
#       flash[:alert].should == "You must sign out to view that resource."
#     end
#
#     it 'should assign admin to @admin' do
#       get :new, params: {id: @admin.id}
#       assigns[:admin].should == @admin
#     end
#
#     it 'should assign new User to @user' do
#       get :new, params: {id: @admin.id}
#       assigns[:user].should be_a(User)
#     end
#
#     it 'should assign new Event to @event' do
#       get :new, params: {id: @admin.id}
#       assigns[:event].should be_an(Event)
#     end
#   end # New
#
#   describe 'POST /facilities/:id/sign_ups' do
#     it 'should create a User' do
#       expect{ post :create, params: @sign_up_params }
#             .to change{ User.users.count }.by(1)
#     end
#
#     it 'should create an Event' do
#       expect{ post :create, params: @sign_up_params }
#             .to change{ Event.count }.by(1)
#     end
#
#     context 'Success' do
#       before do
#         allow(UsersMailer).to receive(:new_event).and_call_original
#         post :create, params: @sign_up_params
#         @user = assigns[:user]
#         @event = assigns[:event]
#       end
#
#       it "should assign @admin facilitity to new User's :facilities" do
#         @user.facilities.include?(@admin.facility)
#       end
#
#       it 'should assign params to new User' do
#         @user.name.should == @sign_up_params[:sign_up][:name]
#         @user.email.should == @sign_up_params[:sign_up][:email]
#         @user.phone.should == @sign_up_params[:sign_up][:phone]
#         @user.role.should == 'user'
#       end
#
#       it 'should assign params to Event' do
#         @event.start_time.in_time_zone('Alaska').to_i.should ==
#               @sign_up_params[:sign_up][:start_time].in_time_zone('Alaska').to_i
#         @event.admin == @admin
#         @event.reload.facility.should == @admin.facility # reload necesary because this is set is save callback.
#       end
#
#       it 'should redirect_to root' do
#         expect(response).to redirect_to(root_path)
#         flash[:notice].should == 'Your acocunt has been created. Thank you.'
#       end
#
#       it 'should sign in new user' do
#         controller.current_user.should == @user
#       end
#
#       it 'should send an new_event email to @user' do
#         expect(UsersMailer).to have_received(:new_event)
#       end
#     end
#
#     context 'Failure' do
#       before do
#         @sign_up_params[:sign_up][:name] = nil
#         @sign_up_params[:sign_up][:start_time] = nil
#         post :create, params: @sign_up_params
#         @user = assigns[:user]
#         @event = assigns[:event]
#       end
#
#       it 'should render :new' do
#         expect(response).to render_template(:new)
#       end
#
#       it 'should add an error to @user' do
#         @user.errors[:name].include?("can't be blank").should == true
#       end
#
#       it 'should add error to @event' do
#         @event.errors[:start_time].include?("can't be blank").should == true
#       end
#
#       it '@event should not have user must exist error if user does not save' do
#         @event.errors[:user].include?("must exist").should == false
#       end
#     end
#
#     specify ':password_confirmation must match :password' do
#       @sign_up_params[:sign_up][:password_confirmation] = 'password'
#       post :create, params: @sign_up_params
#       assigns[:user].errors[:password_confirmation]
#              .include?("doesn't match Password").should == true
#     end
#
#     it 'should not save a user, if Event params fail' do
#       @sign_up_params[:sign_up][:start_time] = nil
#       expect{ post :create, params: @sign_up_params }
#             .not_to change{ User.count }
#     end
#   end # Create
# end
