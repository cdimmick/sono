require 'rails_helper'

describe Patronage, type: :model do
  describe 'Associations' do
    it{ should belong_to :user }
    it{ should belong_to :facility }
  end
end
