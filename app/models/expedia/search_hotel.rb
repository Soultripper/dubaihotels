module Expedia
  class SearchHotel < Expedia::Search

    attr_reader :ids, :responses

    DEFAULT_SLICE = 200

    def initialize(ids, search_criteria)
      super search_criteria
      @ids, @responses = ids, []
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def self.page_hotels(ids, search_criteria, options={}, &block)
      new(ids, search_criteria).page_hotels(options, &block)
    end

    def search(options={})
      params = search_params.merge(hotel_params)
      create_list_response Expedia::Client.get_list(params)
    end

    def page_hotels(options={}, &block)
      responses, slice_by = [],  (options[:slice] || DEFAULT_SLICE)

      time = Benchmark.realtime do 
        (conn = Expedia::Client.http).in_parallel do 
          ids.each_slice(slice_by) do |sliced_ids|          
            Log.info "Sending request of #{sliced_ids.count} hotels to Expedia:"
            params = search_params.merge(hotel_params(sliced_ids)).merge(Expedia::Client.credentials)
            responses << conn.post( Expedia::Client.url + '/ean-services/rs/hotel/v3/list', params)
          end
        end
      end

      Log.info "Expedia query for #{ids.count} hotels took #{time}s to complete"

      collect(responses,&block)


    end 

    def collect(responses, &block)
      responses.each do |response|
        begin
          list_response = create_list_response(Expedia::Client.parse_response(response))
          list_response.page_hotels(&block) if list_response.valid?
        rescue Exception => msg
          Log.error "Expedia error response: #{response}, #{msg}"
        end        
      end
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
