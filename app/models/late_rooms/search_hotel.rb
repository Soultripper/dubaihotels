module LateRooms
  class SearchHotel < LateRooms::Search

    attr_reader :ids, :responses

    DEFAULT_SLICE = 200
    INIT_BATCH_SIZE = 50

    def initialize(ids, search_criteria)
      super search_criteria
      @ids, @responses = ids, []
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def self.for_availability(hotel_id, search_criteria, options={})
      new([hotel_id], search_criteria).search(options)
    end

    def self.page_hotels(ids, search_criteria, options={}, &block)
      new(ids, search_criteria).page_hotels(options, &block)
    end

    def search(options={})
      params = search_params.merge(hotel_params)
      create_list_response LateRooms::Client.hotels(params)
    end


    # def page_hotels(options={}, &block)
    #   responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

    #   time = Benchmark.realtime do 
    #     (conn = LateRooms::Client.http).in_parallel do 
    #       ids.each_slice(slice_by) do |sliced_ids|          
    #         Log.info "Sending request of #{sliced_ids.count} hotels to LateRooms.com:"
    #         params = search_params.merge(hotel_params(sliced_ids))
    #         responses << conn.get( LateRooms::Client.url, params)
    #       end
    #     end
    #   end

    #   hotels = collect_hotels(concat_responses(responses))
    #   Log.info "Collected #{hotels.count} hotels out of #{responses.count} LateRooms responses for comparison in #{time}s"
    #   yield hotels if block_given?
    # end 

    # def concat_responses(responses)
    #   responses.map {|response| create_list_response Nokogiri.XML(response.body)}
    # end

    # def collect_hotels(list_responses)
    #   list_responses.flat_map {|list_response| list_response.hotels}
    # end

    def hotel_params(custom_ids=nil)
      {
        hids: (custom_ids || ids).join(','),
        rtype: 7
      }
    end


    def page_hotels(options={}, &block)
      requests, slice_by = [],  (options[:slice] || DEFAULT_SLICE)
      HydraConnection.in_parallel do
        requests << request(ids.take(INIT_BATCH_SIZE), &block) 
        ids.drop(INIT_BATCH_SIZE).each_slice(slice_by) { |hotel_ids| requests << request(hotel_ids, &block) }
        requests
      end
    end

    def request(hotel_ids=nil, &success_block)
      req =  HydraConnection.get LateRooms::Client.url, :params=> search_params.merge(hotel_params(hotel_ids))
      req.on_complete do |response|
        Log.debug "Laterooms.com response complete: uri=#{response.request.url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"

        if response.success?
          #Log.debug response.body
          begin
            hotels_list = create_list_response Nokogiri.XML(response.body)
          rescue Exception => msg
            Log.error "Laterooms.com error response: #{response.body}, #{msg}"
            nil  
          end
          if hotels_list
            block_given? ? (yield hotels_list.hotels) : hotels_list
          else
            nil
          end
        elsif response.timed_out?
          Log.error ("Laterooms.com request timed out")
        elsif response.code == 0
          Log.error(response.return_message)
        else
          Log.error("Laterooms.com HTTP request failed: #{response.code}, body=#{response.body}")
        end
      end
      req
    end

    def fetch_hotels(hotel_ids=nil, &success_block)
      req = request(hotel_ids, &success_block)
      response = req.run
      create_list_response Nokogiri.XML(response.body)
    end

  end
end
