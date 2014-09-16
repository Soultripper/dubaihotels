class HotelComparer

  attr_reader :hotels_map, :found_provider_hotels, :dictionary, :key

  def initialize(hotels_map, found_provider_hotels, key)
    @hotels_map, @found_provider_hotels, @key = hotels_map, found_provider_hotels, key
  end

  def self.compare(hotels_map, found_provider_hotels, key, &block)
    new(hotels_map, found_provider_hotels, key).compare &block
  end

  def compare(&block)      
    # create_dictionary     
    provider_hotels.each do |provider_hotel|            
      hotel = hotels_map.find_hotel_for key, provider_hotel.id
      if hotel
        yield(hotel, provider_hotel)
      else
        Log.warn "Unable to locate #{key}:  #{provider_hotel.id}"
      end
    end
  end

end





















# class HotelComparer

#   attr_reader :source_hotels, :provider_hotels, :dictionary, :key

#   def initialize(source_hotels, provider_hotels, key)
#     @source_hotels, @provider_hotels, @key = source_hotels.to_a, provider_hotels.to_a, key
#   end

#   def self.compare(source_hotels, provider_hotels, key, &block)
#     new(source_hotels, provider_hotels, key).compare &block
#   end

#   def compare(&block)      
#     add_unmatched_hotels     
#     search_dictionary &block
#   end

#   def add_unmatched_hotels
#     new_hotels, unmatached_hotel_ids = [], []
#     time = Benchmark.realtime do 
#       hotel_ids_set = Set.new(provider_hotels.map(&:id))
#       provider_hotel_ids = Set.new(source_hotels.map(&key))
#       unmatached_hotel_ids = hotel_ids_set.difference(provider_hotel_ids)
#       new_hotels = HotelComparisons.by_provider_ids(key, unmatached_hotel_ids.to_a).to_a  if !unmatached_hotel_ids.empty?
#     end
#     source_hotels.concat(new_hotels) if new_hotels.length > 0
#   end

#   def search_dictionary(&block)    
#     create_dictionary     
#     provider_hotels.each do |provider_hotel|        
#       match = lookup(provider_hotel)
#       if match
#         yield(match, provider_hotel)
#       else
#         Log.warn "Unable to locate #{key}:  #{provider_hotel.id}"
#       end
#     end
#   end

#   def create_dictionary
#     @dictionary =  {}
#     source_hotels.each  do |hotel| 
#       next unless hotel[key]
#       hash_key = hotel[key].to_s[0..3]
#       @dictionary[hash_key] ||= []
#       @dictionary[hash_key] << hotel 
#     end
#     @dictionary
#   end

#   def lookup(provider_hotel)
#     hash_key = provider_hotel.id.to_s[0..3]
#     @dictionary[hash_key].find {|s_hotel| s_hotel[key] == provider_hotel.id} if @dictionary[hash_key]
#   end

#   def compared_hotels
#     source_hotels.select {|h| h.provider_deals.empty?}
#   end

# end