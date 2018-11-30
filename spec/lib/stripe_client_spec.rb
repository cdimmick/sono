require 'rails_helper'

describe StripeClient, type: :lib do
  before do
    @source = 'tok_mastercard'
    @customer_email = 'test@test.com'
    @client = StripeClient.new
  end

  describe '#get_customer(email, source)' do
    it 'should return customer data' do
      VCR.use_cassette('lib/stripe_client/get_customer') do
        data = @client.get_customer(@customer_email, @source)
        data.id.should == 'cus_E4D3SUJ4h1RAYP'
      end
    end
  end

  describe '#create_charge(customer_id, amount, description)' do
    it 'should create a charge' do
      VCR.use_cassette('lib/stripe_client/create_charge') do
        customer_id = @client.get_customer(@customer_email, @source).id

        data = @client.create_charge(customer_id, 100.00, description: 'Description')

        data.id.should == 'ch_1Dc4d1Byuh66yo7xykmk214v'
        data.description.should == 'Description'
        data.amount.should == 10000 # Stripe uses amount in cents
      end
    end
  end

  describe '#charge(email, source, amount, description: nil)' do
    it 'should create a charge' do
      VCR.use_cassette('lib/stripe_client/charge') do
        data = @client.charge(@customer_email, @source, 200.00, description: 'Description')

        data.id.should == 'ch_1Dc4mEByuh66yo7xA9QOjtud'
        data.description.should == 'Description'
        data.amount.should == 20000
      end
    end
  end
end
