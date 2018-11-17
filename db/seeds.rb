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

User.create(role: 'user', email: 'user@test.com', password: 'Password123!')
User.create(role: 'admin', email: 'admin@test.com', password: 'Password123!')
User.create(role: 'super_admin', email: 'super_admin@test.com', password: 'Password123!')
