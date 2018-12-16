class UsersMailer < ApplicationMailer
  def new_user(user_id, password)
    @password = password
    @user = User.find(user_id)

    mail(
      to: @user.email,
      subject: "Your new Account on.."
    )
  end

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
