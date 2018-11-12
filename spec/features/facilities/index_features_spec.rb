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
#       skip
#       visit '/facilities'
#       find_all('.facility_row').count.should == 10
#     end
#   end
# end
