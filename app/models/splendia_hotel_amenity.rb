class SplendiaHotelAmenity < ActiveRecord::Base
  attr_accessible :splendia_hotel_id, :splendia_amenity_id, :flag


  def self.process
    amenities = SplendiaAmenity.where('flag is not null')

    unflagged.map do |hotel|
      hotel.flag = 0
      amenities.each do |amenity|
        if hotel.all_facilities.include? amenity.description.downcase
          if (hotel.flag & amenity.flag != amenity.flag)
            Log.debug "Matched #{amenity.description}, #{amenity.flag}"
            hotel.flag += amenity.flag.to_i
          end
        end
      end
      hotel.flag += 1 if hotel.wifi?
      hotel.save! if hotel.flag > 0 
      hotel
    end


  end

  def all_facilities
    s = "#{activities},#{business_facilities},#{entertainment_facilities},#{extra_common_areas},#{general_facilities},#{parking},#{services},#{shops},#{shuttle_service},#{wellness_facilities}".downcase.split(',')
    s.map &:trim
  end

  def wifi?
    internet_free.to_i != 2
  end

  def self.unflagged
    where('flag is null')
  end
end
