require 'rails_helper'

describe Charge, type: :model do
  before do
    @charge = build(:charge)
  end

  it '' do
    @charge.save!
  end
  describe 'Associations' do
    it{ should belong_to :event }
  end

  describe 'Validations' do
    it{ should validate_presence_of :email }
    it{ should validate_presence_of :stripe_token }
    it{ should validate_presence_of :amount }
  end
end
