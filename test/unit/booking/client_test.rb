require 'test_helper'

class Booking::ClientTest < ActiveSupport::TestCase


  test "booking.com dubai hotels" do
    VCR.use_cassette('booking/hotels/dubai') do
      hotels = Booking::Client.hotels_in 'Dubai'
      assert_equal 20, hotels.length
    end
  end

end
