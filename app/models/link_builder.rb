module LinkBuilder


  def booking_aid
      371919
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


  def booking_link(location, hotel_id)
    "http://www.booking.com/searchresults.en-gb.html?city=#{location.city_id}&highlighted_hotels=#{hotel_id}&checkin=#{start_date}&checkout=#{end_date}&aid=371919&lang=en-gb&selected_currency=#{currency_code}" 
  end

end