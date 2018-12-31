class FacilitiesMailer < ApplicationMailer
  def new_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @event.contact.email,
      subject: "New #{t('app.name')} Appointment: #{@user.name}"
    )
  end

  def changed_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @event.contact.email,
      subject: "#{t('app.name')} Appointment Changed: #{@user.name}"
    )
  end
end
