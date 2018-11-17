# require 'rails_helper'
#
# describe 'Facilities Index Features', type: :feature, js: true do
#   before do
#     @super_admin = create(:super_admin)
#     10.times{ create(:facility) }
#   end
#
#   context 'As SuperAdmin' do
#     before do
#       login @super_admin
#     end
#
#     it 'should list facilities' do
#       visit '/facilities'
#       sleep 3
#       save_and_open_page
#       page.find_all('tr').count.should == 10
#     end
#   end
# end
