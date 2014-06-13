class Providers::Etb::Room < Providers::Base
  attr_accessible :breakfast_included, :breakfast_text, :cancellation_policy, :capacity, :check_in, :check_out, :child_policy, :early_booking, :etb_hotel_id, :facilities, :last_minute_booking, :name, :non_refundable, :rate_id, :room_description, :room_id, :room_image, :under_occupancy

  def self.cols
    "etb_hotel_id,room_id, name, rate_id, capacity, under_occupancy, early_booking, last_minute_booking, non_refundable, breakfast_included, check_in, check_out, room_description, room_image, facilities, breakfast_text, cancellation_policy, child_policy"
  end
end
