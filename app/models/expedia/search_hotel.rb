module Expedia
  class SearchHotel < Expedia::Search

    attr_reader :ids, :responses


    def initialize(ids, search_criteria)
      super search_criteria
      @ids, @responses = ids, []
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def search(options={})
      create_list_response Expedia::Client.get_list(params(options))
    end

    def params(options={})
      search_params.merge(hotel_params).merge(options)
    end

    def hotel_params(custom_ids=nil)
      {
        hotelIdList: (custom_ids || ids).join(',')
      }
    end


  end
end
