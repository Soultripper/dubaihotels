# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# cities = City.create([{ name: 'Dubai', booking_id: '-782831' }, {name: 'London', booking_id: '-2601889'}])
amenities = "Wifi,Central Location,Family Friendly,Parking,Gym,Boutique,Non-smoking rooms,Pet Friendly,Pool,Restaurant,Spa".split(',')

HotelAmenity.delete_all
flag = 1
amenities.each_with_index do |a, idx|
  HotelAmenity.create({ id: idx+1, name: a, value: a.parameterize, flag: flag})
  flag=flag<<1
end

Country.seed_from_booking
City.seed_from_booking
Region.seed_from_booking
BookingHotel.seed_from_booking
RegionBookingHotelLookup.seed_from_booking