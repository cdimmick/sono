# require 'rails_helper'
#
# describe EventsController, type: :controller do
#   before do
#
#   end
#
#   describe 'GET /facilities/:id/events' do
#     describe 'Permissions' do
#       specify 'Only Super Admin can access' do
#         sign_in @super_admin
#         expect(get :index).not_to redirect_to(root_url)
#       end
#
#       specify 'Lower Roles cannot' do
#         sign_in create(:admin)
#         expect(get :index).to redirect_to(root_url)
#       end
#
#       specify 'Non-signed in users cannot' do
#         expect(get :index).to redirect_to(root_url)
#       end
#     end
#
#     context 'As SuperAdmin' do
#       before do
#         sign_in @super_admin
#       end
#
#       it 'should assign all facilities to @facilities' do
#         get :index
#         assigns(:facilities).should == [@facility]
#       end
#
#       it 'should render index template' do
#         expect(get :index).to render_template(:index)
#       end
#     end
#   end # end Index
# end
