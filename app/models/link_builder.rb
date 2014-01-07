module LinkBuilder


  def booking_aid
    371919
  end

  def tradedoubler_aid
    2351254
  end

  def booking_link_detailed(booking_hotel)

    # "#{booking_hotel.url}?aid=#{booking_aid}
    #     &label=hotel-#{booking_hotel.id}
    #     &utm_source=hot5
    #     &utm_medium=SPPC
    #     &utm_content=search
    #     &utm_campaign=en
    #     &utm_term=hotel-#{booking_hotel.id}
    #     &lang=en
    #     &checkin_monthday=22
    #     &checkin_year_month=2013-12
    #     &checkout_monthday=23
    #     &checkout_year_month=2013-12
    #     &selected_currency=GBP"

    "#{booking_hotel.url}?aid=#{booking_aid}&label=hotel-#{booking_hotel.id}&utm_source=hot5&utm_medium=SPPC&utm_content=search&utm_campaign=en&utm_term=hotel-#{booking_hotel.id}&lang=en&checkin=#{start_date}&checkout=#{end_date}&selected_currency=#{currency_code}"
  end

  def booking_link(hotel)
    "#{hotel.booking_url}?aid=#{booking_aid}&label=hotel-#{hotel.booking_hotel_id}&utm_source=hot5&utm_medium=SPPC&utm_content=search&utm_campaign=en&utm_term=hotel-#{hotel.booking_hotel_id}&lang=en&checkin=#{start_date}&checkout=#{end_date}&selected_currency=#{currency_code}"
  end


  # def booking_link(location, hotel_id)
  #   "http://www.booking.com/searchresults.en-gb.html?city=#{location.city_id}&highlighted_hotels=#{hotel_id}&checkin=#{start_date}&checkout=#{end_date}&aid=371919&lang=en-gb&selected_currency=#{currency_code}" 
  # end

  def expedia_link(hotel_id)
    str_start_date = start_date.strftime('%d/%m/%Y')
    str_end_date = end_date.strftime('%d/%m/%Y')      
    url = "http://www.expedia.co.uk/pubspec/scripts/eap.asp?GOTO=HOTDETAILS&Indate=#{str_start_date}&Outdate=#{str_end_date}&NumAdult=#{no_of_adults}&Numroom=#{no_of_rooms}&HotId=#{hotel_id}&tabtype=0"
    "http://clkuk.tradedoubler.com/click?p=21874&a=#{tradedoubler_aid}&g=952779&url=" + url
  end

  def hotels_link(hotel_id)
    str_start_date = start_date.strftime('%d/%m/%Y')
    str_end_date = end_date.strftime('%d/%m/%Y')  
    url = "http://www.hotels.com/PPCHotelDetails?hotelid=#{hotel_id}&numberOfRooms=#{no_of_rooms}&childrenPerRoom=0,0&childAgesPerRoom=0&adultsPerRoom=#{no_of_adults},1&arrivalDate=#{str_start_date}&departureDate=#{str_end_date}&view=rates"    
    "http://clkuk.tradedoubler.com/click?p=21874&a=#{tradedoubler_aid}&g=17461688&url=" + url
  end
end
