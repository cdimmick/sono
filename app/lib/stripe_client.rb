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
      amount: (amount * 100).to_i,
      description: description,
      currency: 'usd'
    )
  end

  def charge(email, source, amount, description: nil)
    customer = get_customer(email, source)
    create_charge(customer.id, amount, description: description)
  end
end


#   @amount = 500
#
#   customer = Stripe::Customer.create(
#     :email => params[:stripeEmail],
#     :source  => params[:stripeToken]
#   )
#
#   charge = Stripe::Charge.create(
#     :customer    => customer.id,
#     :amount      => @amount,
#     :description => 'Rails Stripe customer',
#     :currency    => 'usd'
#   )
#
#   # redirect_to
# rescue Stripe::CardError => e
#   redirect_to new_charge_path, alert: e.message
# end
