class ChargesController < ApplicationController
  def create
    @amount = 12.50

    begin
      stripe_client.charge(
        params[:stripeEmail],
        params[:stripeToken],
        @amount,
        description: 'Sonostream Live'
      )

      notice = "Thank you for your purchase. You will recieve an email with further instructions."
      redirect_to "#{params[:callback_path]}?paid=true", notice: notice
    rescue Stripe::CardError => e
      flash.now[:alert] = e.message
    end
  end

  private

  def stripe_client
    @stripe_client ||= StripeClient.new
  end
end
