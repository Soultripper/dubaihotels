class ProviderHotel < ActiveRecord::Base
  attr_accessible :address, :amenities, :city, :country_code, :description, :hotel_id, :hotel_link, :latitude, :longitude, :name, :postal_code, :provider_hotel_id, :provider_id, :star_rating, :state_province, :user_rating

  belongs_to :hotel
  def self.find_by(provider, provider_id)
    where(provider: provider, provider_id: provider_id).first
  end

  def self.for_hotels(ids)
    where(hotel_id: ids)
  end

  def self.for_comparison(hotel_ids)
    for_hotels(hotel_ids).select([:hotel_id, :provider, :provider_id, :hotel_link])
  end

  def to_json
    {
      provider: provider,
      description: description_clean,
      user_rating: user_rating
    }
  end

  def description_clean
    CGI::unescapeHTML(description.gsub(/<\/?[^>]*>/,""))
  end
end
