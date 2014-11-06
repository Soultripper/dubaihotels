module Expedia
  class SearchHotel < Expedia::Search

    attr_reader :responses

    DEFAULT_SLICE = 200
    INIT_BATCH_SIZE = 50

    def initialize(search_criteria, ids)
      super search_criteria, ids
      @responses = []
    end

    def self.search(search_criteria, ids, options={})
      new(search_criteria, ids).search(options)
    end

    def self.request_hotels(search_criteria, ids, options={}, &block)
      new(search_criteria, ids).request_hotels(options, &block)
    end

    def search(options={})
      params = search_params.merge(hotel_params)
      create_list_response Expedia::Client.get_list(params)
    end

    def request_hotels(options={}, &block)
      responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      time = Benchmark.realtime do 
        (conn = Expedia::Client.http).in_parallel do 
          responses << request(conn, ids.take(INIT_BATCH_SIZE))
          ids.drop(INIT_BATCH_SIZE).each_slice(slice_by) do |sliced_ids|          
            Log.debug "Sending request of #{sliced_ids.count} hotels to Expedia:"
            responses << request(conn, sliced_ids)
          end
        end
      end

      Log.debug "Expedia query for #{ids.count} hotels took #{time}s to complete"

      collect(responses, &block)
    end 

    def request(conn, hotel_ids = nil)
      params = search_params.merge(hotel_params(hotel_ids || ids)).merge(Expedia::Client.credentials)
      conn.post( Expedia::Client.url + '/ean-services/rs/hotel/v3/list', params)
    end

    def fetch_hotels(hotel_ids = nil)
      params = search_params.merge(hotel_params(hotel_ids || ids)).merge(Expedia::Client.credentials)
      response = Expedia::Client.http.post( Expedia::Client.url + '/ean-services/rs/hotel/v3/list', params)
      create_list_response(Expedia::Client.parse_response(response))
    end

    def collect(responses, &block)
      responses.each do |response|
        # begin
          xml = Expedia::Client.parse_response(response)
          list_response = create_list_response(xml)
          list_response.page_hotels(&block) if list_response.valid?
          list_response = nil
          xml = nil
        # rescue Exception => msg
        #   Log.error "Expedia error response: #{response}, #{msg}"
        # end        
      end
      responses = nil
    end



    # def params(options={})
    #   search_params.merge(hotel_params).merge(options)
    # end

    def hotel_params(custom_ids=nil)
      {
        hotelIdList: (custom_ids || ids).join(',')
      }
    end


  end
end
