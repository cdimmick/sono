class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('OUTGOING_EMAIL_ADDRESS')
  layout 'mailer'

  add_template_helper(ApplicationHelper)
end
