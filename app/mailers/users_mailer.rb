class UsersMailer < ApplicationMailer
  def new_user(user_id, password)
    @password = password
    @user = User.find(user_id)

    mail(
      to: @user.email,
      subject: "Your account has been created at #{t('app.site')}" 
    )
  end

  def new_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @user.email,
      subject: "New #{t('app.name')} appointment at #{@event.facility.name}"
    )
  end

  def changed_event(event_id)
    @event = Event.find(event_id)
    @user = @event.user

    mail(
      to: @user.email,
      subject: "Changed #{t('app.name')} appointment at #{@event.facility.name}"
    )
  end

  def new_charge(charge_id)
    @charge = Charge.find(charge_id)
    mail(
      to: @charge.event.user.email,
      subject: "Someone has gifted a #{t('app.name')} to you!"
    )
  end
end
