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

ActiveRecord::Schema[8.1].define(version: 2026_03_31_080824) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "aircraft", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "business_seats", null: false
    t.integer "comfort_plus_seats", null: false
    t.datetime "created_at", null: false
    t.integer "economy_seats", null: false
    t.string "model", null: false
    t.integer "total_seats", null: false
    t.datetime "updated_at", null: false
  end

  create_table "airports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city", null: false
    t.string "code", limit: 3, null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.boolean "is_international", default: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_airports_on_code", unique: true
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_api_keys_on_email", unique: true
    t.index ["token"], name: "index_api_keys_on_token", unique: true
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_key_id", null: false
    t.datetime "created_at", null: false
    t.uuid "flight_id", null: false
    t.string "passenger_name", limit: 100, null: false
    t.string "reference", limit: 6, null: false
    t.uuid "seat_id", null: false
    t.string "status", default: "confirmed", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key_id", "flight_id"], name: "index_bookings_on_api_key_id_and_flight_id", unique: true, where: "((status)::text = 'confirmed'::text)"
    t.index ["api_key_id"], name: "index_bookings_on_api_key_id"
    t.index ["flight_id"], name: "index_bookings_on_flight_id"
    t.index ["reference"], name: "index_bookings_on_reference", unique: true
    t.index ["seat_id"], name: "index_bookings_on_seat_id"
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
    t.datetime "created_at", null: false
    t.integer "departures_per_day", null: false
    t.uuid "destination_id", null: false
    t.integer "duration_minutes", null: false
    t.string "flight_number_prefix", null: false
    t.boolean "is_international", default: false
    t.uuid "origin_id", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id"], name: "index_routes_on_aircraft_id"
    t.index ["destination_id"], name: "index_routes_on_destination_id"
    t.index ["origin_id", "destination_id"], name: "index_routes_on_origin_id_and_destination_id", unique: true
    t.index ["origin_id"], name: "index_routes_on_origin_id"
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "features", default: [], array: true
    t.uuid "flight_id", null: false
    t.boolean "is_available", default: true, null: false
    t.string "seat_class", null: false
    t.string "seat_number", limit: 4, null: false
    t.string "seat_type", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "seat_number"], name: "index_seats_on_flight_id_and_seat_number", unique: true
    t.index ["flight_id"], name: "index_seats_on_flight_id"
    t.index ["is_available"], name: "index_seats_on_is_available"
    t.index ["seat_class"], name: "index_seats_on_seat_class"
  end

  add_foreign_key "bookings", "api_keys"
  add_foreign_key "bookings", "flights"
  add_foreign_key "bookings", "seats"
  add_foreign_key "flights", "aircraft"
  add_foreign_key "flights", "routes"
  add_foreign_key "routes", "aircraft"
  add_foreign_key "routes", "airports", column: "destination_id"
  add_foreign_key "routes", "airports", column: "origin_id"
  add_foreign_key "seats", "flights"
end
