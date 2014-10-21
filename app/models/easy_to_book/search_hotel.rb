module EasyToBook
  class SearchHotel < EasyToBook::Search

    attr_reader :ids

    DEFAULT_SLICE = 250

    def initialize(ids, search_criteria)
       super search_criteria
        @ids = ids
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end


    def self.for_availability(id, search_criteria, params={})
      new([id], search_criteria).for_availability(params)
    end


    def self.page_hotels(ids, search_criteria, options={}, &block)
      new(ids, search_criteria).page_hotels(options, &block)
    end

    def search(options={}) 
      params = {:Hotellist => {:Hotelid => ids}}.merge(search_params.merge(options)) 
      create_list_response EasyToBook::Client.search_availability(params)
    end

    def for_availability(options={})   
      params = {:Hotellist => {:Hotelid => ids}}.merge(search_params.merge(options)) 
      create_list_response EasyToBook::Client.search_availability(params)
    end

    # def page_hotels(options={}, &block)
    #   responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

    #   time = Benchmark.realtime do 
    #     (conn = EasyToBook::Client.http).in_parallel do 
    #       ids.each_slice(slice_by) do |sliced_ids|                       
    #         builder = make_request sliced_ids, options
    #         Log.info "Sending request of #{sliced_ids.count} hotels to EasyToBook:"
    #         responses << conn.post(EasyToBook::Client.uri, builder.to_xml)      
    #       end
    #     end
    #   end

    #   hotels = collect_hotels(concat_responses(responses))
    #   Log.info "Collected #{hotels.count} hotels out of #{responses.count} EasyToBook responses for comparison in #{time}s"
    #   yield hotels if block_given?
    # end 

    # def make_request(hotel_ids, options)
    #   request_params = {:Hotellist => {:Hotelid => hotel_ids}}.merge(search_params.merge(options)) 
    #   EasyToBook::Client.request_builder(:SearchAvailability, request_params)
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
        ids.each_slice(slice_by) do |hotel_ids| 
          requests << request(hotel_ids, options, &block) 
        end

        requests
      end
    end

    def request(hotel_ids=nil, options={}, &success_block)
      xml_builder = xml_request (hotel_ids || ids), options
      headers = {'Content-Type'=> "application/xml; charset=utf-8"}

      req = HydraConnection.post EasyToBook::Client.uri, :body=> xml_builder.to_xml, headers: headers

      req.on_complete do |response|
        Log.debug "EasyToBook response complete: uri=#{response.request.base_url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"
        if response.success?
          #Log.debug response.body
          begin
            hotels_list = create_list_response Nokogiri.XML(response.body)
          rescue Exception => msg
            Log.error "EasyToBook error response: #{response.body}, #{msg}"
            nil  
          end
          yield hotels_list.hotels if block_given? and hotels_list          
        elsif response.timed_out?
          Log.error ("EasyToBook request timed out")
        elsif response.code == 0
          Log.error(response.return_message)
        else
          Log.error("EasyToBook HTTP request failed: #{response.code}, body=#{response.body}")
        end
      end
      req
    end

    def xml_request(hotel_ids, options)
      request_params = {:Hotellist => {:Hotelid => hotel_ids}}.merge(search_params.merge(options)) 
      EasyToBook::Client.request_builder(:SearchAvailability, request_params)
    end


  end
end
