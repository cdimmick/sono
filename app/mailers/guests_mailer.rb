class GuestsMailer < ApplicationMailer
  def invite(event_id, email)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: email,
      subject: 'You have been invited'
    )
  end
end
