module Expedia
  class Image
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :hotel, class_name: 'Expedia::Hotel'

    field :_id, type: String, default: ->{ self.URL}

    def self.create_from_csv(row)
      fields = row.to_hash
      hotelId = fields.first[1]
      hotel = Expedia::Hotel.find(hotelId)
      hotel.images.find_or_create_by(fields) if hotel
    end


  end

end
