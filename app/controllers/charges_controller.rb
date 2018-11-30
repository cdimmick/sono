class ChargesController < ApplicationController
  def create
    callback = params[:callback]
    amount = 12.50
    email = params[:stripeEmail]
    token = params[:stripeToken]

    begin
      stripe_client.charge(
        email,
        token,
        amount,
        description: 'Sonostream Live'
      )

      # Send email, create Charge, Spec this.
      GuestsMailer.purchase()

      notice = "Thank you for your purchase. You will recieve an email with further instructions."
      redirect_to "#{callback}?paid=true", notice: notice
    rescue Stripe::CardError => e
      redirect_to "#{callback}?paid=false", alert: e.message
    end
  end

  private

  def stripe_client
    @stripe_client ||= StripeClient.new
  end
end
