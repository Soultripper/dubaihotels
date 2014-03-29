class EasyToBook::Admin 

  # download file and reprocess 
  
  class << self 

    # def update_hotels(last_change = 1.week.ago)
    #   Agoda::Feeds.changed_hotels(msincedate: last_change.strftime('%Y%m%d'))
    # end

    # def remove_closed(last_change = 1.week.ago, offset=0, rows=1000)
    #   # delete_all if offset == 0
    #   while !(hotel_ids = Expedia::Client.changed_hotels(last_change: last_change.strftime('%F'), show_closed: 1, offset: offset)).empty?
    #     process_closed_ids hotel_ids.map {|h| h['hotel_id'].to_i}
    #     offset += rows
    #   end
    #   offset
    # end

    # def process_closed_ids(hotel_ids)
    #   Hotel.where(booking_hotel_id: hotel_ids).update_all('booking_hotel_id = null')
    # end

    # def add_opened(last_change = 1.week.ago, offset=0, rows=1000)
    #   # delete_all if offset == 0
    #   ids = []
    #   while !(hotel_ids = Expedia::Client.changed_hotels(last_change: last_change.strftime('%F'), show_closed: 0, offset: offset)).empty?
    #     ids.concat hotel_ids.map {|h| h['hotel_id'].to_i}
    #     offset += rows
    #   end
    #   retrieve_opened ids
    # end

    # def retrieve_opened(hotel_ids)
    #   ExpediaHotel.fetch(hotel_ids)
    #   ExpediaHotelImage.fetch(hotel_ids)
    #   ExpediaHotelDescription.fetch(hotel_ids)
    #   ExpediaHotelAmenity.fetch(hotel_ids)
    # end

  end
end