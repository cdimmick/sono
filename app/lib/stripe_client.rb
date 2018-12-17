class StripeClient
  def get_customer(email, source)
    Stripe::Customer.create(
      email: email,
      source: source
    )
  end

  def create_charge(customer_id, amount, description: nil)
    charge = Stripe::Charge.create(
      customer: customer_id,
      amount: (amount.to_f * 100).to_i,
      description: description,
      currency: 'usd'
    )
  end

  def charge(email, source, amount, description: nil)
    customer = get_customer(email, source)
    create_charge(customer.id, amount, description: description)
  end
end
