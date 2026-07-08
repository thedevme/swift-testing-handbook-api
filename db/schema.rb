# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_08_165501) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "aircraft", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aisle_type", default: "single"
    t.integer "business_seats", null: false
    t.integer "comfort_plus_seats", null: false
    t.datetime "created_at", null: false
    t.integer "economy_seats", null: false
    t.integer "first_seats", default: 0
    t.string "model", null: false
    t.integer "total_seats", null: false
    t.datetime "updated_at", null: false
  end

  create_table "airlines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "airline_type"
    t.string "code", limit: 2, null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "logo_png"
    t.string "logo_svg"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_airlines_on_code", unique: true
    t.index ["name"], name: "index_airlines_on_name"
  end

  create_table "airports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city", null: false
    t.string "code", limit: 3, null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.integer "elevation_ft"
    t.integer "hub_tier", default: 3
    t.boolean "is_international", default: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "name", null: false
    t.string "state"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_airports_on_code", unique: true
    t.index ["hub_tier"], name: "index_airports_on_hub_tier"
    t.index ["state"], name: "index_airports_on_state"
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "reader_name"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_api_keys_on_email", unique: true
    t.index ["reader_name"], name: "index_api_keys_on_reader_name"
    t.index ["token"], name: "index_api_keys_on_token", unique: true
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_key_id", null: false
    t.datetime "created_at", null: false
    t.uuid "flight_id", null: false
    t.boolean "is_outbound", default: true, null: false
    t.string "passenger_name", limit: 100, null: false
    t.string "reference", limit: 6, null: false
    t.uuid "return_booking_id"
    t.uuid "seat_id", null: false
    t.string "status", default: "confirmed", null: false
    t.string "trip_type", default: "one_way", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key_id", "flight_id"], name: "index_bookings_on_api_key_id_and_flight_id", unique: true, where: "((status)::text = 'confirmed'::text)"
    t.index ["api_key_id", "return_booking_id"], name: "index_bookings_on_api_key_id_and_return_booking_id"
    t.index ["api_key_id"], name: "index_bookings_on_api_key_id"
    t.index ["flight_id"], name: "index_bookings_on_flight_id"
    t.index ["is_outbound"], name: "index_bookings_on_is_outbound"
    t.index ["reference"], name: "index_bookings_on_reference", unique: true
    t.index ["return_booking_id"], name: "index_bookings_on_return_booking_id"
    t.index ["seat_id"], name: "index_bookings_on_seat_id"
    t.index ["trip_type"], name: "index_bookings_on_trip_type"
  end

  create_table "flight_legs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "flight_id", null: false
    t.uuid "itinerary_id", null: false
    t.integer "leg_number", null: false
    t.uuid "seat_id", null: false
    t.string "status", default: "confirmed", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_flight_legs_on_flight_id"
    t.index ["itinerary_id", "leg_number"], name: "index_flight_legs_on_itinerary_id_and_leg_number", unique: true
    t.index ["itinerary_id"], name: "index_flight_legs_on_itinerary_id"
    t.index ["seat_id"], name: "index_flight_legs_on_seat_id"
    t.index ["status"], name: "index_flight_legs_on_status"
  end

  create_table "flights", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "aircraft_id", null: false
    t.integer "business_price_cents", null: false
    t.integer "comfort_plus_price_cents", null: false
    t.datetime "created_at", null: false
    t.integer "delay_minutes"
    t.string "diverted_to", limit: 3
    t.integer "duration_minutes", null: false
    t.integer "economy_price_cents", null: false
    t.integer "first_price_cents"
    t.string "flight_number", limit: 10, null: false
    t.uuid "route_id", null: false
    t.datetime "scheduled_arrival_at", null: false
    t.datetime "scheduled_departure_at", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id"], name: "index_flights_on_aircraft_id"
    t.index ["flight_number"], name: "index_flights_on_flight_number"
    t.index ["route_id"], name: "index_flights_on_route_id"
    t.index ["scheduled_departure_at"], name: "index_flights_on_scheduled_departure_at"
    t.index ["status"], name: "index_flights_on_status"
  end

  create_table "itineraries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_key_id", null: false
    t.datetime "created_at", null: false
    t.integer "leg_count", default: 0, null: false
    t.string "passenger_name", limit: 100, null: false
    t.string "reference", limit: 8, null: false
    t.string "status", default: "confirmed", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["api_key_id", "status"], name: "index_itineraries_on_api_key_id_and_status"
    t.index ["api_key_id"], name: "index_itineraries_on_api_key_id"
    t.index ["reference"], name: "index_itineraries_on_reference", unique: true
    t.index ["status"], name: "index_itineraries_on_status"
  end

  create_table "purchases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "order_number", null: false
    t.integer "price_cents"
    t.string "product_id"
    t.datetime "purchased_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_purchases_on_email"
    t.index ["order_number"], name: "index_purchases_on_order_number", unique: true
  end

  create_table "routes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "aircraft_id", null: false
    t.uuid "airline_id"
    t.datetime "created_at", null: false
    t.integer "departures_per_day", null: false
    t.uuid "destination_id", null: false
    t.integer "duration_minutes", null: false
    t.string "flight_number_prefix", null: false
    t.boolean "is_international", default: false
    t.uuid "origin_id", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id"], name: "index_routes_on_aircraft_id"
    t.index ["airline_id"], name: "index_routes_on_airline_id"
    t.index ["destination_id"], name: "index_routes_on_destination_id"
    t.index ["origin_id", "destination_id"], name: "index_routes_on_origin_id_and_destination_id", unique: true
    t.index ["origin_id"], name: "index_routes_on_origin_id"
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "column_letter", limit: 1, default: "A", null: false
    t.datetime "created_at", null: false
    t.string "deck", limit: 10, default: "main", null: false
    t.string "features", default: [], array: true
    t.uuid "flight_id", null: false
    t.boolean "is_available", default: true, null: false
    t.integer "row", default: 1, null: false
    t.string "seat_class", null: false
    t.string "seat_number", limit: 4, null: false
    t.string "seat_type", null: false
    t.datetime "updated_at", null: false
    t.index ["deck"], name: "index_seats_on_deck"
    t.index ["flight_id", "seat_number"], name: "index_seats_on_flight_id_and_seat_number", unique: true
    t.index ["flight_id"], name: "index_seats_on_flight_id"
    t.index ["is_available"], name: "index_seats_on_is_available"
    t.index ["seat_class"], name: "index_seats_on_seat_class"
  end

  create_table "weather_conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "airport_id", null: false
    t.string "condition", null: false
    t.datetime "created_at", null: false
    t.integer "feels_like_f"
    t.date "forecast_date", null: false
    t.integer "humidity_percent"
    t.string "icon"
    t.integer "precipitation_chance_percent"
    t.integer "temperature_f", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility_miles"
    t.string "wind_direction"
    t.integer "wind_speed_mph"
    t.index ["airport_id", "forecast_date"], name: "index_weather_conditions_on_airport_id_and_forecast_date", unique: true
    t.index ["airport_id"], name: "index_weather_conditions_on_airport_id"
    t.index ["forecast_date"], name: "index_weather_conditions_on_forecast_date"
  end

  add_foreign_key "bookings", "api_keys"
  add_foreign_key "bookings", "bookings", column: "return_booking_id"
  add_foreign_key "bookings", "flights"
  add_foreign_key "bookings", "seats"
  add_foreign_key "flight_legs", "flights"
  add_foreign_key "flight_legs", "itineraries"
  add_foreign_key "flight_legs", "seats"
  add_foreign_key "flights", "aircraft"
  add_foreign_key "flights", "routes"
  add_foreign_key "itineraries", "api_keys"
  add_foreign_key "routes", "aircraft"
  add_foreign_key "routes", "airlines"
  add_foreign_key "routes", "airports", column: "destination_id"
  add_foreign_key "routes", "airports", column: "origin_id"
  add_foreign_key "seats", "flights"
  add_foreign_key "weather_conditions", "airports"
end
