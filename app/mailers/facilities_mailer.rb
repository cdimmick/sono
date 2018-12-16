class FacilitiesMailer < ApplicationMailer
  def new_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @user.email,
      subject: 'New Appointment Sono'
    )
  end

  def changed_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @user.email,
      subject: 'Changed Appt'
    )
  end
end
