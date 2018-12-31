json.extract! facility, :id, :name, :phone, :created_at, :updated_at
address = facility.address || Address.new

json.address do
  json.street address.street
  json.street2 address.street2
  json.city address.city
  json.state address.full_state
  json.zip address.zip
  json.timezone address.timezone
  json.longitude address.longitude
  json.latitude address.latitude
end

json.url facility_url(facility, format: :json)
