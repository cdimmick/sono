Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [40.7143528, -74.0059731],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

Facility.destroy_all

50.times do |n|
  f = Facility.new(
    name: Faker::Company.name,
    phone: Faker::PhoneNumber.phone_number
  )

  a = Address.new(
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Address::STATES.keys.sample,
    zip: Faker::Address.zip,
  )

  f.address = a
  f.save!

  puts "Facility #{n} created!"
end

User.destroy_all

facility = Facility.all.sample

User.create(role: 'user', email: 'user@test.com', password: 'Password123!', name: Faker::Name.name)
User.create(role: 'admin', email: 'admin@test.com', password: 'Password123!', facility_id: facility.id, name: Faker::Name.name)
User.create(role: 'super_admin', email: 'super_admin@test.com', password: 'Password123!', name: Faker::Name.name)

50.times do |n|
  u = User.create(role: 'user', email: "test#{n}@test.com", password: 'Password123', name: Faker::Name.name, phone: Faker::PhoneNumber.phone_number)
  u.facilities << facility
  u.save!
end
