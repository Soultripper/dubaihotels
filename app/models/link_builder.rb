class LinkBuilder
  extend Forwardable

  attr_reader :search_criteria, :hotel, :provider_hotel

  def_delegators :search_criteria, :start_date, :end_date, :no_of_adults, :no_of_rooms, :currency_code, :total_nights, :children
  def_delegators :provider_hotel, :provider_id, :hotel_link, :provider

  BOOKING_AID       = 371919
  TRADEDOUBLER_AID  = 2351254
  LATEROOMS_AID     = 15182
  VENERE_AID        = 2015826
  AGODA_AID         = 1620684
  EASY_TO_BOOK_AID  = 280828334

  def initialize(search_criteria, hotel, provider_hotel)
    @search_criteria, @hotel, @provider_hotel  = search_criteria, hotel, provider_hotel
  end

  def self.create_link(search_criteria, provider_hotel)
    new(search_criteria, provider_hotel.hotel, provider_hotel).create_link
  end

  def booking
    "#{hotel_link}?aid=#{BOOKING_AID}&label=hotel-#{provider_id}&utm_source=hot5&utm_medium=SPPC&utm_content=search&utm_campaign=en&utm_term=hotel-#{provider_id}&lang=en&checkin=#{start_date}&checkout=#{end_date}&selected_currency=#{currency_code}"
  end

  def expedia
    str_start_date = start_date.strftime('%d/%m/%Y')
    str_end_date = end_date.strftime('%d/%m/%Y')      
    url = "http://www.expedia.co.uk/pubspec/scripts/eap.asp?GOTO=HOTDETAILS&Indate=#{str_start_date}&Outdate=#{str_end_date}&NumAdult=#{no_of_adults}&Numroom=#{no_of_rooms}&HotId=#{provider_id}&tabtype=0"
    "http://clkuk.tradedoubler.com/click?p=21874&a=#{TRADEDOUBLER_AID}&g=952779&url=" + url
  end

  # def hotels_com
  #   str_start_date = start_date.strftime('%d/%m/%Y')
  #   str_end_date = end_date.strftime('%d/%m/%Y')  
  #   url = "http://www.hotels.com/PPCHotelDetails?hotelid=#{provider_id}&numberOfRooms=#{no_of_rooms}&childrenPerRoom=0,0&childAgesPerRoom=0&adultsPerRoom=#{no_of_adults},1&arrivalDate=#{str_start_date}&departureDate=#{str_end_date}&view=rates"    
  #   "http://clkuk.tradedoubler.com/click?p=21874&a=#{TRADEDOUBLER_AID}&g=17461688&url=" + url
  # end

  def laterooms
    str_start_date = start_date.strftime('%Y%m%d')
    url = "#{hotel_link}?d=#{str_start_date}&n=#{total_nights}&a=#{no_of_adults}&cur=#{currency_code}".gsub('[[PARTNERID]]', LATEROOMS_AID.to_s)
  end

  def venere
    qs =  "?htid=#{provider_id}&lg=en&ref=#{VENERE_AID}"
    qs += "&sd=#{start_date.day}&sm=#{start_date.month}&sy=#{start_date.year}"
    qs += "&ed=#{end_date.day}&em=#{end_date.month}&ey=#{end_date.year}"
    qs += "&pval=#{no_of_adults}"
    qs += "&rval=#{no_of_rooms}"
    qs += "&cur=#{currency_code}"

    "http://www.venere.com/hotel/#{qs}"
  end

  def splendia
    str_start_date = start_date.strftime('%F')
    str_end_date = end_date.strftime('%F')  
    "#{hotel_link}&datestart=#{str_start_date}&dateend=#{str_end_date}"
  end

  def agoda
    #can added footer and header urls
    qs =  "?HotelCode=#{provider_id}"
    qs += "&CID=#{AGODA_AID}"
    qs += "&CkInDay=#{start_date.day}&CkInMonth=#{start_date.month}&CkInYear=#{start_date.year}"
    qs += "&CkOutDay=#{end_date.day}&CkOutMonth=#{end_date.month}&CkOutYear=#{end_date.year}"
    qs += "&NumberOfAdults=#{no_of_adults}"
    qs += "&NumberOfRooms=#{no_of_rooms}"
    qs += "&NumberOfChildren=#{children.length}"
    qs += "&currency=#{currency_code}"

    "http://ajaxsearch.partners.agoda.com/partners/partnersearch.aspx#{qs}"
  end

  def easy_to_book

    str_start_date = start_date.strftime('%d-%m-%Y')
    str_end_date = end_date.strftime('%d-%m-%Y')


    qs =  "?amu=#{EASY_TO_BOOK_AID}"
    qs += "&arrival=#{str_start_date}"
    qs += "&departure=#{str_end_date}"
    qs += "&currency=#{currency_code}"
    qs += "&prs_arr[0]=#{no_of_adults}"
    qs += "&hph=1"
    qs += "&utm_term=hotel-#{provider_id}"
    qs += "&utm_source=Broadbase+Ventures+Ltd&utm_medium=affiliate&utm_content=etb4&utm_campaign=en"

    "#{hotel_link}#{qs}"
  end



  def create_link(default_link = nil)  
    return unless search_criteria and hotel and provider_hotel
    respond_to?(provider.to_sym) ? send(provider.to_sym) : default_link
  end

end
