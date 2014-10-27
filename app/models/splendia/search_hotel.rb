module Splendia
  class SearchHotel < Splendia::Search

    attr_reader :ids, :responses

    DEFAULT_SLICE = 150
    INIT_BATCH_SIZE = 0

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
      create_list_response Splendia::Client.hotels(params)
    end


    def page_hotels(options={}, &block)
      responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      time = Benchmark.realtime do 
        (conn = Splendia::Client.http).in_parallel do 
          ids.each_slice(slice_by) do |sliced_ids|          
            Log.info "Sending request of #{sliced_ids.count} hotels to Splendia:"
            params = search_params.merge(hotel_params(sliced_ids))
            responses << conn.get( Splendia::Client.url, params)
          end
        end
      end

      hotels = collect_hotels(concat_responses(responses))
      Log.info "Collected #{hotels.count} hotels out of #{responses.count} Splendia responses for comparison in #{time}s"
      yield hotels if block_given?
    end 

    def concat_responses(responses)
      responses.map {|response| create_list_response Nokogiri.XML(response.body)}
    end

    def collect_hotels(list_responses)
      list_responses.flat_map {|list_response| list_response.hotels}
    end

    def hotel_params(custom_ids=nil)
      {
        hotels: (custom_ids || ids).join(',')
      }
    end


    def page_hotels(options={}, &block)
      requests, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      HydraConnection.in_parallel do
        #requests << request(ids.take(INIT_BATCH_SIZE), &block) 
        ids.each_slice(slice_by) do |hotel_ids| 
          requests << request(hotel_ids, options, &block) 
        end
        requests
      end
    end

    def request(hotel_ids=nil, options={}, &success_block)
      req = HydraConnection.get Splendia::Client.url, :params=> search_params.merge(hotel_params(hotel_ids))

      req.on_complete do |response|
        Log.debug "Splendia response complete: uri=#{response.request.base_url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"
        if response.success?
          #Log.debug response.body
          begin
            hotels_list = create_list_response Nokogiri.XML(response.body)
          rescue Exception => msg
            Log.error "Splendia error response: #{response.body}, #{msg}"
            nil  
          end
          if hotels_list
            block_given? ? (yield hotels_list.hotels) : hotels_list
          else
            nil
          end         
        elsif response.timed_out?
          Log.error ("Splendia request timed out")
        elsif response.code == 0
          Log.error(response.return_message)
        else
          Log.error("Splendia HTTP request failed: #{response.code}, body=#{response.body}")
        end
      end
      req
    end

    def fetch_hotels(hotel_ids=nil)
      request(hotel_ids).run.handled_response
    end

  end
end
