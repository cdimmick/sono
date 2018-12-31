class ApplicationMailer < ActionMailer::Base
  default from: 'todo@change_me.com'
  layout 'mailer'

  add_template_helper(ApplicationHelper)
end
