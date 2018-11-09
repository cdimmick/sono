require 'rails_helper'

describe Facility, type: :model do
  describe 'Associations' do
    it{ should have_many(:admins).class_name('User') }

    it{ should have_one :address }
  end

  describe 'Validations' do
    it{ should validate_presence_of :name }
  end
end
