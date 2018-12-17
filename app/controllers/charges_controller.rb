class ChargesController < ApplicationController
  before_action :authenticate_super_admin!, only: [:index, :delete]
  before_action :set_charge, only: [:destroy]

  def create
    @event = Event.find(params[:event_id])

    if @event.charges.count > 0
      render json: {message: 'A copy of SonoStream has already beem purchased.'}
      return
    end

    email = params[:stripeEmail]
    amount = params[:amount]

    begin
      charge = stripe_client.charge(
        email,
        params[:stripeToken],
        amount,
        description: 'Sonostream Live'
      )

      # TODO: Send email, create Charge, Spec this.
      @charge = Charge.create!(
        event_id: @event.id,
        amount: amount,
        email: email,
        stripe_id: charge[:id]
      )

      GuestsMailer.new_charge(@charge.id).deliver_later
      UsersMailer.new_charge(@charge.id).deliver_later

      render json: {message: 'Thank you for your purchase.'}
    rescue Stripe::CardError => card_error
      render json: {message: card_error}, status: :unprocessable_entity
    rescue Stripe::InvalidRequestError => invalid_stripe_request
      render json: {message: invalid_stripe_request}, status: :unprocessable_entity
    end
  end

  def index
    #TODO spec
    @charges = Charge.all
  end

  def destroy
    #TODO spec
    @charge.destroy
    redirect_to charges_path, notice: 'Charge has been destroyed'
  end

  private

  def set_charge
    @charge = Charge.find(params[:id])
  end

  def stripe_client
    @stripe_client ||= StripeClient.new
  end
end
