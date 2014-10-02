require 'digest/bubblebabble'


class HotelRoomSearch
  extend Forwardable

  attr_reader :hotel, :search_criteria, :finished

  def initialize(hotel, search_criteria)
    @hotel, @search_criteria = hotel, search_criteria
  end

  def hotel_id
    hotel.id
  end

  def self.check_availability(hotel_id, search_criteria)
    new(hotel_id, search_criteria, channel).find_or_create
  end

  def self.find_or_create(hotel_id, search_criteria)
    HotelRoomSearch.new(hotel_id, search_criteria).find_or_create   
  end

  def find_or_create
    Rails.cache.fetch cache_key do 
      Log.info "Starting new room search: #{cache_key}"
      self
    end       
  end

  def start
    return self if @started
    @rooms, @finished = [], false
    @started = true
    persist
    check_availability
  end

  def check_availability    
    # RoomWorker.perform_async hotel_id, cache_key 
    RoomWorker.new.perform hotel_id, cache_key 
    self
  end

 def results
    {
      hotel_id: hotel_id,
      rooms: rooms_results,
      finished: @finished
    }
  end

  def rooms_results
    @rooms.sort_by {|r| r[:price].to_f}
  end

  def persist
    Rails.cache.write(cache_key, self, expires_in: HotelsConfig.cache_expiry, race_condition_ttl: 5)
  end

  def add_rooms(rooms)
    @rooms.concat(rooms)
    Log.debug "#{rooms.count} rooms found"
    persist
  end

  def cache_key
    @cache_key ||= Digest::MD5.hexdigest(search_criteria.as_json.merge({hotel_id: hotel_id}).to_s)
  end

  def channel
    search_criteria.channel_hotel hotel_id
  end

  def finish
    @finished = true
    persist
  end
   

end