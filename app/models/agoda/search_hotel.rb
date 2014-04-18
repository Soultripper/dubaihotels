module Agoda
  class SearchHotel < Agoda::Search

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

    def page_hotels(options={}, &block)
      responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      time = Benchmark.realtime do 
        (conn = Agoda::Client.http).in_parallel do 
          ids.each_slice(slice_by) do |sliced_ids|                       
            builder = make_request sliced_ids, options
            Log.info "Sending request of #{sliced_ids.count} hotels to Agoda:\n #{builder.to_xml}"
            responses << conn.post(Agoda::Client.url, builder.to_xml)      
          end
        end
      end

      hotels = collect_hotels(concat_responses(responses))
      Log.info "Collected #{hotels.count} hotels out of #{responses.count} Agoda responses for comparison in #{time}s"
      yield hotels if block_given?
    end 

    def make_request(hotel_ids, options)
      request_params = {:Id => hotel_ids.join(',')}.merge(search_params.merge(options)) 
      Agoda::Client.request_builder(6, request_params)
    end

    def concat_responses(responses)
      responses.map {|response| create_list_response Nokogiri.XML(response.body)}
    end

    def collect_hotels(list_responses)
      list_responses.flat_map {|list_response| list_response.hotels}
    end

  end
end
