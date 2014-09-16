module HotelsConfig

  PROVIDER_IDS = {
    booking: "Booking",
    expedia: "Expedia",
    splendia: "Splendia",
    easy_to_book: "EasyToBook",
    laterooms: "LateRooms",
    agoda: "Agoda",
    venere: "Venere"
  }

  class << self

    attr_accessor :page_size, :max_page_size, :min_page_size, :max_price, :cache_expiry, :providers

    def setup
      yield self
    end

    def provider_keys
      PROVIDER_IDS.keys
    end

    def provider_names
      providers.map {|p| PROVIDER_IDS[p]}
    end
  end
end