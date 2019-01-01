# Geocoder.configure(lookup: :test)
#
# Geocoder::Lookup::Test.set_default_stub(
#   [
#     {
#       'coordinates'  => [40.7143528, -74.0059731],
#       'address'      => 'New York, NY, USA',
#       'state'        => 'New York',
#       'state_code'   => 'NY',
#       'country'      => 'United States',
#       'country_code' => 'US'
#     }
#   ]
# )

Facility.destroy_all

f = Facility.new(
  name: Faker::Company.name,
  phone: Faker::PhoneNumber.phone_number
)

a = Address.new(
  street: '4218 S. Mt. Angeles Rd.',
  city: "Port Angeles",
  state: 'WA',
  zip: '98362'
)

f.address = a
f.save!

User.create!(role: 'admin', email: "admin_#{f.id}@test.com", password: 'Password123!', name: "Admin #{f.id}", facility_id: f.id)

puts "Facility created!"

User.destroy_all

facility = Facility.all.sample
admin = User.create(role: 'admin', email: 'admin@test.com', password: 'Password123!', facility_id: facility.id, name: Faker::Name.name)

User.create(role: 'user', email: 'user@test.com', password: 'Password123!', name: Faker::Name.name)
User.create(role: 'super_admin', email: 'super_admin@test.com', password: 'Password123!', name: Faker::Name.name)

3.times do |n|
  u = User.create(role: 'user', email: "test#{n}@test.com", password: 'Password123', name: Faker::Name.name, phone: Faker::PhoneNumber.phone_number)
  u.facilities << facility
  u.save!
end

20.times do
  Event.create!(start_time: Time.now + Random.rand(24..500).hours, user_id: User.all.sample.id, admin_id: admin.id)
end
