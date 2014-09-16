class ProviderHotelImage < ActiveRecord::Base
  attr_accessible :id, :hotel_id,  :url,  :width,  :height, :byte_size, :thumbnail_url, :default_image, :remote_url, :cdn, :provider, :provider_id

  has_one :hotel
  def self.find_by(provider, provider_id)
    where(provider: provider, provider_id: provider_id).first
  end

  def self.for_hotels(ids)
    includes(:hotel).where(hotel_id: ids)
  end

  def self.for_comparison(hotel_ids)
    for_hotels(hotel_ids).select([:hotel_id, :provider, :provider_id, :hotel_link])
  end

  def self.by_ranked_order
    select(" 
      *,
        case 
        when provider = 'expedia'     then 4 
        when provider = 'booking'     then 3
        when provider = 'agoda'       then 2
        when provider = 'laterooms'   then 1
        when provider = 'easy_to_book' then 0
        else -1
        end as ranking
    ").order('ranking desc, default_image desc')
  end


  def to_json
    {
      url: url,
      thumbnail_url: thumbnail_url
    }
  end
end
