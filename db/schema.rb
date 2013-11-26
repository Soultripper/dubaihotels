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

ActiveRecord::Schema.define(:version => 20131122170958) do

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
  end

  add_index "booking_hotels", ["geog"], :name => "booking_hotels_geog_idx"

  create_table "cities", :force => true do |t|
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

  add_index "cities", ["country_code"], :name => "cities_country_code_idx"
  add_index "cities", ["geog"], :name => "cities_geog_idx"
  add_index "cities", ["name"], :name => "cities_name_idx"

  create_table "countries", :force => true do |t|
    t.string   "area"
    t.string   "country_code"
    t.string   "language_code"
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
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
    t.text "description"
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
    t.text "services"
    t.text "general_facilities"
    t.text "extra_common_areas"
    t.text "entertainment_facilities"
    t.text "business_facilities"
    t.text "activities"
    t.text "wellness_facilities"
    t.text "shops"
    t.text "internet"
    t.text "internet_connection"
    t.text "parking"
    t.text "shuttle_service"
    t.text "internet_free"
    t.text "internet_connection_free"
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
    t.integer "geog",              :limit => 0
    t.text    "description"
    t.integer "amenities"
    t.integer "agoda_hotel_id"
    t.integer "etb_hotel_id"
  end

  add_index "hotels", ["booking_hotel_id"], :name => "index_hotels_on_booking_hotel_id", :unique => true
  add_index "hotels", ["city", "country_code"], :name => "hotels_city_country_code_idx"
  add_index "hotels", ["ean_hotel_id"], :name => "ean_hotel_id_idx"
  add_index "hotels", ["geog"], :name => "hotels_geog_idx"
  add_index "hotels", ["longitude", "latitude"], :name => "index_hotels_on_location"
  add_index "hotels", ["name", "city"], :name => "index_hotels_on_name_city"
  add_index "hotels", ["star_rating", "city"], :name => "index_hotels_on_star_rating_and_city"

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

  create_table "leaderboards", :force => true do |t|
    t.string   "name"
    t.float    "score"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "locations", :force => true do |t|
    t.string  "city"
    t.integer "city_id"
    t.string  "region"
    t.integer "region_id"
    t.string  "country"
    t.string  "country_code"
    t.string  "language_code"
    t.float   "longitude"
    t.float   "latitude"
    t.string  "slug"
    t.integer "geog",          :limit => 0
    t.integer "etb_city_id"
  end

  add_index "locations", ["slug"], :name => "locations_slug_idx"

  create_table "region_booking_hotel_lookups", :force => true do |t|
    t.integer "region_id"
    t.integer "booking_hotel_id"
  end

  add_index "region_booking_hotel_lookups", ["region_id", "booking_hotel_id"], :name => "region_booking_hotel_lookups_region_id_booking_hotel_id_idx"

  create_table "regions", :force => true do |t|
    t.integer "region_id"
    t.string  "country_code"
    t.string  "language_code"
    t.string  "name"
    t.string  "region_type"
  end

  create_table "scores", :force => true do |t|
    t.string   "name"
    t.float    "score"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

end
