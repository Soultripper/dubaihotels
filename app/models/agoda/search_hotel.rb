module Agoda
  class SearchHotel < Agoda::Search

    attr_reader :ids

    DEFAULT_SLICE = 100
    INIT_BATCH_SIZE = 50

    def initialize(ids, search_criteria)
       super search_criteria
        @ids = ids
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def self.for_availability(id, search_criteria, params={})
      new(id, search_criteria).for_availability(params)
    end

    def self.page_hotels(ids, search_criteria, options={}, &block)
      new(ids, search_criteria).page_hotels(options, &block)
    end

    def search(options={}) 
      params = {:Id => ids.join(',')}.merge(search_params.merge(options)) 
      create_list_response Agoda::Client.search_availability(params)
    end

    def for_availability(options={})   
      params = {:Id => ids}.merge(search_params.merge(options)) 
      create_list_response Agoda::Client.get_availability(params)
    end

    # def page_hotels(options={}, &block)
    #   responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

    #   time = Benchmark.realtime do 
    #     (conn = Agoda::Client.http).in_parallel do 
    #       ids.each_slice(slice_by) do |sliced_ids|                       
    #         builder = xml_request sliced_ids, options
    #         Log.info "Sending request of #{sliced_ids.count} hotels to Agoda:\n"
    #         responses << conn.post(Agoda::Client.url, builder.to_xml)      
    #       end
    #     end
    #   end

    #   hotels = collect_hotels(concat_responses(responses))
    #   Log.info "Collected #{hotels.count} hotels out of #{responses.count} Agoda responses for comparison in #{time}s"
    #   yield hotels if block_given?
    # end 

   

    # def concat_responses(responses)
    #   responses.map {|response| create_list_response Nokogiri.XML(response.body)}
    # end

    # def collect_hotels(list_responses)
    #   list_responses.flat_map {|list_response| list_response.hotels}
    # end

    def page_hotels(options={}, &block)
      requests, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      HydraConnection.in_parallel do
        requests << request(ids.take(INIT_BATCH_SIZE), &block)  
        ids.drop(INIT_BATCH_SIZE).each_slice(slice_by) do |hotel_ids|
          requests << request(hotel_ids, options, &block) 
        end

        requests
      end
    end

    def request(hotel_ids=nil, options={}, &success_block)
      xml_builder = xml_request (hotel_ids || ids), options
      headers = {'Content-Type'=> "application/xml; charset=utf-8"}

      req = HydraConnection.post Agoda::Client.url, :body=> xml_builder.to_xml, headers: headers

      req.on_complete do |response|
        Log.debug "Agoda response complete: uri=#{response.request.url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"
        if response.success?
          #Log.debug response.body
          begin
            hotels_list = create_list_response Nokogiri.XML(response.body)
          rescue Exception => msg
            Log.error "Agoda error response: #{response.body}, #{msg}"
            nil  
          end
          if hotels_list and hotels_list.hotels.count > 0
            Log.debug "Agoda: Found #{hotels_list.hotels.count} hotels out of #{(hotel_ids || ids).count}"

            block_given? ? (yield hotels_list.hotels) : hotels_list
          else
            nil
          end 
        elsif response.timed_out?
          Log.error ("Agoda request timed out")
        elsif response.code == 0
          Log.error(response.return_message)
        else
          Log.error("Agoda HTTP request failed: #{response.code}, body=#{response.body}")
        end
      end
      req
    end


    def xml_request(hotel_ids, options)
      request_params = {:Id => hotel_ids.join(',')}.merge(search_params.merge(options)) 
      Agoda::Client.request_builder(6, request_params)
    end

    def fetch_hotels(hotel_ids=nil)
      request(hotel_ids).run.handled_response
    end

  end

end
