class SearchFactory

  def self.hotels(provider, ids, search_criteria=SearchCriteria.new, options={})

    klass = case provider
              when :expedia then Expedia::SearchHotel;
              when :etb then EasyToBook::SearchHotel;
              when :agoda then Agoda::SearchHotel;
              when :booking then Booking::SearchHotel;
              when :laterooms then LateRooms::SearchHotel;
              when :splendia then Splendia::SearchHotel;
              when :venere then Venere::SearchHotel;
            end

    results = {count: ids.count}
    results[:time] = Benchmark.realtime { results[:hotels_count] = klass.send(:search, ids, search_criteria, options).hotels.count }
    # results[:hotel_count] = results[:hotels].hotels.count
    results
  end


end