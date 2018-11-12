Facility.destroy_all

10.times do
  f = Facility.create!(
    name: Faker::Company.name
  )
end

User.destroy_all

User.create(role: 'user', email: 'user@test.com', password: 'Password123!')
User.create(role: 'admin', email: 'admin@test.com', password: 'Password123!')
User.create(role: 'super_admin', email: 'super_admin@test.com', password: 'Password123!')
