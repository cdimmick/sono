json.extract! user, :id, :email, :name, :phone, :role, :created_at, :updated_at

if facility = user.facility
  json.facility do
    json.name facility.name
    json.id facility.id
  end
end
