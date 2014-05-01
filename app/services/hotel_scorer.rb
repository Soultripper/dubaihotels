class HotelScorer

  attr_reader :hotel

  def initialize(hotel)
    @hotel = hotel
  end

  def self.score(hotel, reason )
    new(hotel).score reason
  end

  def score(reason)

    points = case reason
      when :hotel_seo then 1
      when :clickthrough then 3
      else 0
      end

    hotel.update_attribute :score, hotel.score += points
  end


end
