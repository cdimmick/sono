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

    it 'should fail to log in if user is not :active' do
      @user.update(active: false)
      login @user
      page.current_path.should == '/users/sign_in'
    end
  end
end
