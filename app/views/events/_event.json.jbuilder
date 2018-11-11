json.extract! event, :id, :user_id, :facility_id, :admin_id, :start_time, :created_at, :updated_at
json.url event_url(event, format: :json)
