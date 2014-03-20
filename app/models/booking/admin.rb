require 'typhoeus/adapters/faraday'

class Booking::Admin 

  class << self 

    def remove_closed(last_change = 1.week.ago, offset=0, rows=1000)
      # delete_all if offset == 0
      while !(hotel_ids = Booking::Client.changed_hotels(last_change: last_change.strftime('%F'), show_closed: 1, offset: offset)).empty?
        process_closed_ids hotel_ids.map {|h| h['hotel_id'].to_i}
        offset += rows
      end
      offset
    end

    def process_closed_ids(hotel_ids)
      Hotel.where(booking_hotel_id: hotel_ids).update_all('booking_hotel_id = null')
    end

    def add_opened(last_change = 1.week.ago, offset=0, rows=1000)
      # delete_all if offset == 0
      ids = []
      while !(hotel_ids = Booking::Client.changed_hotels(last_change: last_change.strftime('%F'), show_closed: 0, offset: offset)).empty?
        ids.concat hotel_ids.map {|h| h['hotel_id'].to_i}
        offset += rows
      end
      retrieve_opened ids
    end

    def retrieve_opened(hotel_ids)
      BookingHotel.fetch(hotel_ids)
      BookingHotelImage.fetch(hotel_ids)
      BookingHotelDescription.fetch(hotel_ids)
      BookingHotelAmenity.fetch(hotel_ids)
    end

  end
end