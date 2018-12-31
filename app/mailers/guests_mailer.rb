class GuestsMailer < ApplicationMailer
  def invite(event_id, email)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: email,
      subject: "#{@user.name} has invited you to a #{t('app.name')}"
    )
  end

  def new_charge(charge_id)
    @charge = Charge.find(charge_id)

    mail(
      to: @charge.email,
      subject: "Thank you for your #{t('app.name')} purchase"
    )
  end
end
