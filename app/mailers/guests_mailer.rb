class GuestsMailer < ApplicationMailer
  def invite(event_id, email)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: email,
      subject: 'You have been invited'
    )
  end

  def new_charge(charge_id)
    @charge = Charge.find(charge_id)

    mail(
      to: @charge.email,
      subject: 'About your charge...'
    )
  end
end
