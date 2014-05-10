module HotelsConfig

  PROVIDER_IDS = {
    booking: :booking_hotel_id,  
    expedia: :ean_hotel_id, 
    splendia: :splendia_hotel_id, 
    easy_to_book: :etb_hotel_id, 
    laterooms: :laterooms_hotel_id, 
    agoda: :agoda_hotel_id,
    venere: :venere_hotel_id
  }

  class << self

    attr_accessor :page_size, :max_page_size, :min_page_size, :max_price, :cache_expiry

    def setup
      yield self
    end
  end
end