# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140407091337) do

  create_table "agoda_amenities", :id => false, :force => true do |t|
    t.integer "id",          :null => false
    t.text    "description"
    t.integer "flag"
  end

  create_table "agoda_cities", :force => true do |t|
    t.integer "agoda_country_id"
    t.string  "city_name"
    t.string  "city_translated"
    t.integer "active_hotels"
    t.float   "longitude"
    t.float   "latitude"
    t.integer "no_area"
  end

  create_table "agoda_countries", :force => true do |t|
    t.integer "agoda_continent_id"
    t.string  "country_name"
    t.string  "country_translated"
    t.integer "active_hotels"
    t.string  "country_iso"
    t.string  "country_iso2"
    t.float   "longitude"
    t.float   "latitude"
  end

  create_table "agoda_hotel_amenities", :id => false, :force => true do |t|
    t.integer "agoda_hotel_id", :null => false
    t.integer "flag"
  end

  create_table "agoda_hotel_facilities", :force => true do |t|
    t.integer "agoda_hotel_id"
    t.string  "group_description"
    t.integer "property_id"
    t.string  "name"
    t.string  "translated_name"
  end

  create_table "agoda_hotel_images", :force => true do |t|
    t.integer "agoda_hotel_id"
    t.string  "image_url"
  end

  create_table "agoda_hotels", :force => true do |t|
    t.integer "chain_id"
    t.string  "chain_name"
    t.integer "brand_id"
    t.string  "brand_name"
    t.string  "hotel_name"
    t.string  "hotel_formerly_name"
    t.string  "hotel_translated_name"
    t.string  "addressline1"
    t.string  "addressline2"
    t.string  "zipcode"
    t.string  "city"
    t.string  "state"
    t.string  "country"
    t.string  "countryisocode"
    t.string  "star_rating"
    t.float   "longitude"
    t.float   "latitude"
    t.string  "url"
    t.string  "checkin"
    t.string  "checkout"
    t.string  "numberrooms"
    t.string  "numberfloors"
    t.string  "yearopened"
    t.string  "yearrenovated"
    t.string  "photo1"
    t.string  "photo2"
    t.string  "photo3"
    t.string  "photo4"
    t.string  "photo5"
    t.text    "overview"
    t.string  "rates_from"
    t.string  "continent_id"
    t.string  "continent_name"
    t.integer "city_id"
    t.integer "country_id"
    t.integer "number_of_reviews"
    t.float   "rating_average"
    t.string  "rates_currency"
    t.integer "geog",                  :limit => 0
  end

  add_index "agoda_hotels", ["geog"], :name => "agoda_hotels_geog_idx"

  create_table "agoda_neighbourhoods", :force => true do |t|
    t.integer "agoda_city_id"
    t.string  "area_name"
    t.string  "area_translated"
    t.integer "active_hotels"
    t.float   "longitude"
    t.float   "latitude"
    t.text    "polygon"
  end

  create_table "agoda_regions", :force => true do |t|
    t.string "name"
    t.string "name_translated"
  end

  create_table "booking_cities", :force => true do |t|
    t.string   "country_code"
    t.string   "language_code"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "timezone_name"
    t.string   "timezone_offset"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "geog",            :limit => 0
    t.string   "simple_name",     :limit => 1024
  end

  add_index "booking_cities", ["country_code"], :name => "cities_country_code_idx"
  add_index "booking_cities", ["geog"], :name => "cities_geog_idx"
  add_index "booking_cities", ["name"], :name => "cities_name_idx"

  create_table "booking_countries", :force => true do |t|
    t.string   "area"
    t.string   "country_code"
    t.string   "language_code"
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "booking_hotel_amenities", :force => true do |t|
    t.integer "booking_hotel_id"
    t.string  "value"
    t.integer "facility_type_id"
    t.integer "booking_facility_type_id"
  end

  create_table "booking_hotel_descriptions", :force => true do |t|
    t.integer "booking_hotel_id"
    t.text    "description"
    t.integer "description_type_id"
  end

  create_table "booking_hotel_facility_types", :force => true do |t|
    t.integer "facility_type_id"
    t.string  "name"
    t.string  "value_type"
    t.string  "language_code"
    t.integer "flag"
  end

  create_table "booking_hotel_images", :force => true do |t|
    t.integer "description_type_id"
    t.integer "booking_hotel_id"
    t.integer "photo_id"
    t.string  "url_max_300"
    t.string  "url_original"
    t.string  "url_square60"
  end

  create_table "booking_hotels", :force => true do |t|
    t.string  "district"
    t.integer "nr_rooms"
    t.string  "city"
    t.string  "check_in_to"
    t.string  "check_in_from"
    t.float   "minrate"
    t.string  "url"
    t.integer "review_nr"
    t.string  "address"
    t.float   "commission"
    t.integer "ranking"
    t.integer "city_id"
    t.string  "review_score"
    t.float   "longitude"
    t.float   "latitude"
    t.integer "max_rooms_in_reservation"
    t.integer "max_persons_in_reservation"
    t.string  "name"
    t.integer "hoteltype_id"
    t.boolean "preferred"
    t.string  "country_code"
    t.boolean "class_is_estimated"
    t.boolean "is_closed"
    t.string  "check_out_to"
    t.string  "check_out_from"
    t.string  "zip"
    t.string  "contractchain_id"
    t.float   "maxrate"
    t.integer "classification"
    t.string  "languagecode"
    t.string  "currencycode"
    t.integer "geog",                       :limit => 0
    t.integer "process_state"
  end

  add_index "booking_hotels", ["geog"], :name => "booking_hotels_geog_idx"

  create_table "booking_region_hotel_lookups", :force => true do |t|
    t.integer "region_id"
    t.integer "booking_hotel_id"
  end

  add_index "booking_region_hotel_lookups", ["region_id", "booking_hotel_id"], :name => "region_booking_hotel_lookups_region_id_booking_hotel_id_idx"

  create_table "booking_region_hotels", :force => true do |t|
    t.integer  "booking_hotel_id"
    t.integer  "booking_region_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "booking_regions", :force => true do |t|
    t.integer "region_id"
    t.string  "country_code"
    t.string  "language_code"
    t.string  "name"
    t.string  "region_type"
  end

  create_table "ean_countries", :force => true do |t|
    t.string "language_code"
    t.string "country_name"
    t.string "country_code"
    t.string "transliteration"
    t.string "continent_id"
  end

  create_table "ean_hotel_attribute_links", :force => true do |t|
    t.integer "ean_hotel_id"
    t.integer "attribute_id"
    t.string  "language_code"
    t.text    "append_text"
  end

  add_index "ean_hotel_attribute_links", ["attribute_id"], :name => "ean_hotel_attribute_links_attribute_id_idx"
  add_index "ean_hotel_attribute_links", ["ean_hotel_id"], :name => "index_ean_hotel_attributes_on_ean_hotel_id"

  create_table "ean_hotel_attributes", :force => true do |t|
    t.integer "attribute_id"
    t.string  "language_code"
    t.string  "description"
    t.string  "attribute_type"
    t.string  "sub_type"
    t.integer "hotel_amenities_id"
  end

  add_index "ean_hotel_attributes", ["attribute_id"], :name => "ean_hotel_attributes_attribute_id_idx"
  add_index "ean_hotel_attributes", ["hotel_amenities_id"], :name => "ean_hotel_attributes_hotel_amenities_id_idx"

  create_table "ean_hotel_descriptions", :force => true do |t|
    t.integer "ean_hotel_id"
    t.string  "language_code"
    t.text    "description"
  end

  create_table "ean_hotel_images", :force => true do |t|
    t.integer "ean_hotel_id"
    t.string  "caption"
    t.string  "url"
    t.integer "width"
    t.integer "height"
    t.integer "byte_size"
    t.string  "thumbnail_url"
    t.boolean "default_image"
  end

  add_index "ean_hotel_images", ["ean_hotel_id"], :name => "index_hotel_images_on_ean_hotel_id"

  create_table "ean_hotels", :force => true do |t|
    t.integer "sequence_number"
    t.string  "name"
    t.string  "address1"
    t.string  "address2"
    t.string  "city"
    t.string  "state_province"
    t.string  "postal_code"
    t.string  "country"
    t.float   "latitude"
    t.float   "longitude"
    t.string  "airport_code"
    t.string  "property_category"
    t.string  "property_currency"
    t.float   "star_rating"
    t.integer "confidence"
    t.string  "supplier_type"
    t.string  "location"
    t.string  "chain_code_id"
    t.string  "region_id"
    t.float   "high_rate"
    t.float   "low_rate"
    t.string  "check_in_time"
    t.string  "check_out_time"
    t.integer "geog",              :limit => 0
    t.string  "nameaddress",       :limit => 1024
  end

  add_index "ean_hotels", ["city"], :name => "ean_hotels_city_idx"
  add_index "ean_hotels", ["country"], :name => "ean_hotels_country_idx"
  add_index "ean_hotels", ["geog"], :name => "ean_hotels_geog_idx"
  add_index "ean_hotels", ["nameaddress"], :name => "ean_hotels_nameaddress_trgm_idx"
  add_index "ean_hotels", ["star_rating", "city"], :name => "index_ean_hotels_on_star_rating_and_city"

  create_table "ean_points_of_interest_coordinates", :force => true do |t|
    t.integer "ean_region_id"
    t.string  "region_name"
    t.string  "region_name_long"
    t.float   "latitude"
    t.float   "longitude"
    t.string  "sub_class"
  end

  create_table "ean_region_coordinates", :force => true do |t|
    t.integer "ean_region_id"
    t.string  "region_name"
    t.float   "latitude"
    t.float   "longitude"
  end

  create_table "ean_regions", :force => true do |t|
    t.string  "region_type"
    t.string  "relative_significance"
    t.string  "sub_class"
    t.string  "region_name"
    t.string  "region_name_long"
    t.integer "parent_region_id"
    t.string  "parent_region_type"
    t.string  "parent_region_name"
    t.string  "parent_region_name_long"
  end

  create_table "ean_room_types", :force => true do |t|
    t.integer "ean_hotel_id"
    t.integer "room_type_id"
    t.string  "language_code"
    t.string  "image"
    t.string  "name"
    t.text    "description"
  end

  create_table "etb_cities", :force => true do |t|
    t.string  "city_name"
    t.float   "longitude"
    t.float   "latitude"
    t.integer "province_id"
    t.string  "province_name"
    t.integer "country_id"
    t.string  "country_name"
    t.string  "url"
    t.float   "city_rank"
    t.string  "country_code"
    t.integer "geog",          :limit => 0
  end

  add_index "etb_cities", ["geog"], :name => "etb_cities_geog_idx"
  add_index "etb_cities", ["geog"], :name => "etb_cities_geog_idx1"

  create_table "etb_countries", :force => true do |t|
    t.string "country_name"
    t.string "country_iso"
    t.string "url"
  end

  create_table "etb_facilities", :force => true do |t|
    t.text    "description"
    t.integer "flag"
  end

  create_table "etb_hotel_descriptions", :force => true do |t|
    t.integer "etb_hotel_id"
    t.text    "description"
    t.text    "important_description"
    t.text    "food_and_beverage_description"
    t.text    "location_description"
    t.text    "public_transportation"
    t.text    "pets_policy"
    t.text    "teaser"
  end

  create_table "etb_hotel_facilities", :force => true do |t|
    t.text    "services"
    t.text    "general_facilities"
    t.text    "extra_common_areas"
    t.text    "entertainment_facilities"
    t.text    "business_facilities"
    t.text    "activities"
    t.text    "wellness_facilities"
    t.text    "shops"
    t.text    "internet"
    t.text    "internet_connection"
    t.text    "parking"
    t.text    "shuttle_service"
    t.text    "internet_free"
    t.text    "internet_connection_free"
    t.text    "amenities"
    t.integer "flag"
  end

  create_table "etb_hotel_images", :force => true do |t|
    t.integer "etb_hotel_id"
    t.integer "room_id"
    t.string  "size"
    t.string  "image"
  end

  create_table "etb_hotels", :force => true do |t|
    t.string  "name"
    t.string  "address"
    t.string  "zipcode"
    t.integer "city_id"
    t.float   "stars"
    t.string  "check_in"
    t.string  "check_out"
    t.string  "picture"
    t.string  "total_rooms"
    t.float   "longitude"
    t.float   "latitude"
    t.string  "hotel_review_score"
    t.string  "hotel_number_reviews"
    t.string  "credit_cards"
    t.string  "phone"
    t.string  "url"
    t.string  "email"
    t.string  "hotel_type"
    t.string  "address_city"
    t.string  "min_price"
    t.integer "geog",                 :limit => 0
  end

  add_index "etb_hotels", ["geog"], :name => "etb_hotels_geog_idx"

  create_table "etb_points_of_interests", :force => true do |t|
    t.string  "name"
    t.float   "longitude"
    t.float   "latitude"
    t.integer "city_id"
    t.string  "url"
  end

  create_table "etb_provinces", :force => true do |t|
    t.string  "name"
    t.integer "country_id"
    t.string  "url"
  end

  create_table "etb_rooms", :force => true do |t|
    t.integer "etb_hotel_id"
    t.integer "room_id"
    t.text    "name"
    t.integer "rate_id"
    t.integer "capacity"
    t.boolean "under_occupancy"
    t.boolean "early_booking"
    t.boolean "last_minute_booking"
    t.boolean "non_refundable"
    t.boolean "breakfast_included"
    t.string  "check_in"
    t.string  "check_out"
    t.text    "room_description"
    t.string  "room_image"
    t.text    "facilities"
    t.text    "breakfast_text"
    t.text    "cancellation_policy"
    t.text    "child_policy"
  end

  create_table "hotel_amenities", :force => true do |t|
    t.string  "name",  :null => false
    t.string  "value"
    t.integer "flag"
  end

  create_table "hotel_images", :force => true do |t|
    t.integer "hotel_id"
    t.string  "caption"
    t.string  "url"
    t.integer "width"
    t.integer "height"
    t.integer "byte_size"
    t.string  "thumbnail_url"
    t.boolean "default_image"
    t.string  "remote_url"
    t.string  "cdn"
  end

  add_index "hotel_images", ["hotel_id"], :name => "index_hotel_images_on_hotel_id"

  create_table "hotel_rooms", :force => true do |t|
    t.integer "hotel_id"
    t.integer "room_type_id"
    t.string  "language_code"
    t.string  "image"
    t.string  "name"
    t.text    "description"
  end

  create_table "hotels", :force => true do |t|
    t.string  "name"
    t.string  "address"
    t.string  "city"
    t.string  "state_province"
    t.string  "postal_code"
    t.string  "country_code"
    t.float   "latitude"
    t.float   "longitude"
    t.float   "star_rating"
    t.float   "high_rate"
    t.float   "low_rate"
    t.string  "check_in_time"
    t.string  "check_out_time"
    t.string  "property_currency"
    t.integer "ean_hotel_id"
    t.integer "booking_hotel_id"
    t.integer "geog",                  :limit => 0
    t.text    "description"
    t.integer "amenities"
    t.integer "agoda_hotel_id"
    t.integer "etb_hotel_id"
    t.float   "booking_user_rating"
    t.float   "ranking"
    t.integer "splendia_hotel_id"
    t.string  "booking_url"
    t.integer "laterooms_hotel_id"
    t.string  "laterooms_url"
    t.string  "hotel_provider"
    t.float   "agoda_user_rating"
    t.float   "laterooms_user_rating"
    t.float   "etb_user_rating"
    t.float   "splendia_user_rating"
    t.float   "user_rating"
    t.integer "matches"
    t.string  "slug",                  :limit => 512
    t.integer "venere_hotel_id"
    t.float   "venere_user_rating"
  end

  add_index "hotels", ["agoda_hotel_id"], :name => "agoda_hotel_id_idx"
  add_index "hotels", ["booking_hotel_id"], :name => "index_hotels_on_booking_hotel_id", :unique => true
  add_index "hotels", ["city", "country_code"], :name => "hotels_city_country_code_idx"
  add_index "hotels", ["ean_hotel_id"], :name => "ean_hotel_id_idx"
  add_index "hotels", ["etb_hotel_id"], :name => "hotels_etb_hotel_id_idx"
  add_index "hotels", ["geog"], :name => "hotels_geog_idx"
  add_index "hotels", ["laterooms_hotel_id"], :name => "index_hotels_on_laterooms_hotel_id"
  add_index "hotels", ["longitude", "latitude"], :name => "index_hotels_on_location"
  add_index "hotels", ["name", "city"], :name => "index_hotels_on_name_city"
  add_index "hotels", ["ranking"], :name => "idx_ranking"
  add_index "hotels", ["slug"], :name => "hotels_slug_idx"
  add_index "hotels", ["star_rating", "city"], :name => "index_hotels_on_star_rating_and_city"
  add_index "hotels", ["state_province"], :name => "hotels_state_province_idx"

  create_table "hotels_ean_hotels_matches_weighted_staging", :id => false, :force => true do |t|
    t.integer "hotel_id",     :null => false
    t.integer "ean_hotel_id", :null => false
    t.float   "weighting"
  end

  create_table "hotels_ean_hotels_within_five_kilometers", :id => false, :force => true do |t|
    t.integer "hotel_id",     :null => false
    t.integer "ean_hotel_id", :null => false
  end

  create_table "hotels_hotel_amenities", :id => false, :force => true do |t|
    t.integer "hotel_id",         :null => false
    t.integer "hotel_amenity_id", :null => false
  end

  add_index "hotels_hotel_amenities", ["hotel_amenity_id"], :name => "index_hotels_hotel_amenities_on_hotel_amenity_id"
  add_index "hotels_hotel_amenities", ["hotel_id"], :name => "index_hotels_hotel_amenities_on_hotel_id"

  create_table "late_rooms_amenities", :force => true do |t|
    t.integer "laterooms_hotel_id"
    t.string  "amenity"
  end

  add_index "late_rooms_amenities", ["laterooms_hotel_id"], :name => "index_laterooms_hotel_id_on_late_rooms_amenities"

  create_table "late_rooms_facilities", :force => true do |t|
    t.text    "description"
    t.integer "flag"
  end

  create_table "late_rooms_hotel_images", :force => true do |t|
    t.integer "laterooms_hotel_id"
    t.string  "image_url"
    t.boolean "default_image"
  end

  add_index "late_rooms_hotel_images", ["laterooms_hotel_id"], :name => "index_laterooms_hotel_id_on_late_rooms_hotel_images"

  create_table "late_rooms_hotels", :force => true do |t|
    t.string  "name"
    t.string  "star_rating"
    t.text    "address1"
    t.string  "city"
    t.string  "county"
    t.string  "postcode"
    t.string  "country"
    t.string  "country_iso"
    t.text    "description"
    t.text    "directions"
    t.string  "image"
    t.text    "images"
    t.float   "longitude"
    t.float   "latitude"
    t.string  "url"
    t.string  "price_from"
    t.string  "max_price"
    t.string  "currency_code"
    t.string  "score_out_of_6"
    t.string  "no_of_reviews"
    t.string  "review_url"
    t.text    "facilities"
    t.string  "accommodation_type"
    t.text    "appeals"
    t.string  "star_accreditor"
    t.string  "created_date"
    t.string  "total_rooms"
    t.text    "cancellation_policy"
    t.string  "cancellation_days"
    t.text    "cancellation_terms"
    t.string  "city_tax_type"
    t.string  "city_tax_value"
    t.string  "city_tax_opted_in"
    t.string  "is_city_tax_area"
    t.string  "check_in_time"
    t.string  "check_out_time"
    t.string  "latest_check_in_time"
    t.integer "geog",                 :limit => 0
    t.float   "star_rating_normal"
  end

# Could not dump table "locations" because of following StandardError
#   Unknown type 'geography' for column 'geog'

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "splendia_amenities", :force => true do |t|
    t.text    "description"
    t.integer "flag"
  end

  create_table "splendia_hotel_amenities", :force => true do |t|
    t.integer "splendia_hotel_id"
    t.string  "amenity"
  end

  create_table "splendia_hotels", :force => true do |t|
    t.string  "name"
    t.string  "country"
    t.string  "city"
    t.integer "city_id"
    t.string  "state_province_name"
    t.string  "state_province_code"
    t.string  "street"
    t.string  "postal_code"
    t.string  "stars"
    t.string  "club"
    t.text    "product_url"
    t.text    "facilities"
    t.text    "description"
    t.float   "latitude"
    t.float   "longitude"
    t.string  "hotel_currency"
    t.string  "category_id"
    t.float   "price"
    t.float   "original_price"
    t.string  "product_name"
    t.integer "product_id"
    t.string  "currency"
    t.string  "stars_rating"
    t.string  "small_image"
    t.string  "big_image"
    t.text    "other_services"
    t.integer "reviews"
    t.string  "rating"
    t.string  "category"
    t.text    "offers"
    t.integer "geog",                :limit => 0
  end

  create_table "venere_hotels", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "last_update"
    t.string   "hotel_type"
    t.integer  "rating"
    t.float    "user_rating"
    t.string   "currency_code"
    t.string   "hotel_amenities"
    t.string   "room_amenities"
    t.float    "price"
    t.text     "location_description"
    t.text     "location_attractions"
    t.string   "geo_id"
    t.text     "address"
    t.string   "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country"
    t.string   "country_iso_code"
    t.string   "state"
    t.string   "region"
    t.string   "province"
    t.string   "city"
    t.string   "place"
    t.string   "city_zone"
    t.text     "hotel_overview"
    t.text     "stay_policy"
    t.text     "service_fees"
    t.text     "breakfast_description"
    t.text     "directions"
    t.string   "location_url"
    t.string   "property_url"
    t.string   "dyn_property_url"
    t.string   "hotel_image_url"
    t.datetime "hotel_image_url_last_update"
    t.string   "hotel_thumb_url"
    t.datetime "hotel_thumb_url_last_update"
    t.string   "hotel_url_finder_image"
    t.datetime "hotel_url_finder_image_last_update"
    t.text     "image_url"
    t.text     "image_url_last_update"
    t.text     "thumb_url"
    t.text     "thumb_url_last_update"
    t.text     "image_title"
    t.string   "tx_id"
  end

end
