module ApplicationHelper
  def display_datetime(datetime)
    datetime.strftime('%D @ %l:%M %p %Z')
  end
end
