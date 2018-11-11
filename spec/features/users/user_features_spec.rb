require 'rails_helper'

describe 'User Features', type: :feature do
  before do
    @user = create(:user)
  end

  context 'Active User' do
    it 'should be able to log in' do
      login @user
      page.current_path.should == '/'
    end
  end
end
