class CreateDbStructure < ActiveRecord::Migration
  def change
    enable_extension "plpgsql"
    enable_extension "postgis"

    create_table "abstract_trip", primary_key: "ab_trip_id", force: :cascade do |t|
      t.integer "category_id"
      t.integer "start_point"
      t.integer "end_point"
      t.time    "duration"
    end

    create_table "customer", primary_key: "customer_id", force: :cascade do |t|
      t.string  "name",     limit: 60
      t.string  "address",  limit: 60
      t.string  "postcode", limit: 10
      t.integer "tel",      limit: 8
      t.string  "email",    limit: 60
    end

# Could not dump table "location" because of following StandardError
#   Unknown type 'geometry(Point,4269)' for column 'point'

  create_table "properties", primary_key: "property_id", force: :cascade do |t|
    t.string "name", limit: 60
    t.string "unit", limit: 5
  end

  create_table "request", primary_key: "request_id", force: :cascade do |t|
    t.integer "cus_id"
    t.float   "weight"
    t.integer "goods_type",        limit: 2
    t.float   "height"
    t.float   "length"
    t.float   "capacity"
    t.time    "time"
    t.string  "other_description", limit: 60
    t.integer "start_point",       limit: 8
    t.integer "end_point",         limit: 8
    t.string  "status",            limit: 15
    t.integer "category_id"
  end

  create_table "schedule", primary_key: "schedule_id", force: :cascade do |t|
    t.time    "estimate_time"
    t.integer "request_id"
  end

  create_table "spatial_ref_sys", primary_key: "srid", force: :cascade do |t|
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

  create_table "supplier", primary_key: "s_id", force: :cascade do |t|
    t.string  "name",    limit: 60
    t.string  "address", limit: 60
    t.integer "tel",     limit: 8
    t.string  "email",   limit: 60
  end

  create_table "trip", id: false, force: :cascade do |t|
    t.integer "trip_id",     limit: 8,  default: "nextval('trip_trip_id_seq'::regclass)", null: false
    t.string  "vehicle_id",  limit: 30,                                                   null: false
    t.integer "ab_trip_id",  limit: 8
    t.integer "schedule_id"
    t.integer "sequent",     limit: 2
  end

  create_table "v_category_properties", id: false, force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "category_id", null: false
    t.float   "value"
  end

  # Could not dump table "vehicle" because of following StandardError
  #   Unknown type 'geometry(Point,4269)' for column 'point'

  create_table "vehicle_category", primary_key: "category_id", force: :cascade do |t|
    t.integer "s_id"
    t.string  "name",        limit: 60
    t.string  "description", limit: 60
  end

  add_foreign_key "abstract_trip", "location", column: "end_point", primary_key: "location_id", name: "abstract_trip_end_point_fkey"
  add_foreign_key "abstract_trip", "location", column: "start_point", primary_key: "location_id", name: "abstract_trip_start_point_fkey"
  add_foreign_key "abstract_trip", "vehicle_category", column: "category_id", primary_key: "category_id", name: "abstract_trip_category_id_fkey"
  add_foreign_key "request", "customer", column: "cus_id", primary_key: "customer_id", name: "request_cus_id_fkey"
  add_foreign_key "schedule", "request", primary_key: "request_id", name: "schedule_request_id_fkey"
  add_foreign_key "trip", "schedule", primary_key: "schedule_id", name: "trip_schedule_id_fkey"
  add_foreign_key "trip", "vehicle", primary_key: "vehicle_id", name: "trip_vehicle_id_fkey"
  add_foreign_key "v_category_properties", "properties", primary_key: "property_id", name: "v_category_properties_property_id_fkey"
  add_foreign_key "v_category_properties", "vehicle_category", column: "category_id", primary_key: "category_id", name: "v_category_properties_v_category_id_fkey"
  add_foreign_key "vehicle", "vehicle_category", column: "category_id", primary_key: "category_id", name: "vehicle_category_id_fkey"
  add_foreign_key "vehicle_category", "supplier", column: "s_id", primary_key: "s_id", name: "vehicle_category_s_id_fkey"
  end
end