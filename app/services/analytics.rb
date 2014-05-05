class Analytics

  IGNORE_AGENTS = ["ADmantX", "Amazon", "Dalvik", "DoCoMo", "WeSEE:Ads", "ia_archiver", "AdsBot-Google", "facebookexternalhit"]

  class << self 

    
    def publish(key, data)

      return false unless data and key
      return false unless valid_user_agent? (data)
      
      Thread.new do 
        add_geo_lookup data[:request]

        user_event_data = user_event(key, data)

        Keen.publish_batch key => [data],  user_event: [user_event_data]

        Log.debug "Published analytics: #{key}"
      end
      true
    end

    def user_event(key, data)
       {
        event_type: key,
        remote_ip: data[:request][:remote_ip],
        data: data
       }
    end

    def valid_user_agent?(data)

      return false unless data

      return true unless data[:request]

      IGNORE_AGENTS.include?(data[:request][:browser]) ? false : true
    end


    def clickthrough(options)
      data = {
        provider: options[:provider],
        search: options[:search_criteria],
        offer: options[:offer],
        hotel: options[:hotel],
        request: options[:request_params]
      }
      publish :clickthrough, data
    end

    def search(options)
      data = {
        search: options[:search_criteria],
        location: options[:location],
        request: options[:request_params]
      }
      publish :search, data
    end


    def hotel_seo(options)
      data = {
        search: options[:search_criteria],
        hotel: options[:hotel],
        request: options[:request_params]
      }
      publish :hotel_seo, data
    end

    def more_hotels(options)
      data = {
        search: options[:search_criteria],
        location: options[:location],
        request: options[:request_params],
        count: options[:count]
      }
      publish :more_hotels, data
    end


    def add_geo_lookup(request)
      return nil unless request and request[:remote_ip]
      loc = Geokit::Geocoders::IpGeocoder.geocode(request[:remote_ip])
      request[:location] = {
          latitude: loc.lat,
          longitude: loc.lng,
          full_address: loc.full_address,
          address: loc.street_address,
          address2: loc.sub_premise,
          city: loc.city,
          province: loc.province,
          district: loc.district,
          state: loc.state,
          post_code: loc.zip,
          country_code: loc.country_code
      } if loc and loc.success
    end
  end

end