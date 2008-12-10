# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 12) do

  create_table "billing_cycles", :force => true do |t|
    t.string   "name",         :null => false
    t.integer  "day_of_month", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.integer  "retainer_hours"
    t.boolean  "retainer_includes_ah", :null => false
    t.integer  "retainer_points"
    t.decimal  "retainer_cost"
    t.decimal  "oh_hourly_rate"
    t.decimal  "ah_hourly_rate"
    t.decimal  "point_rate"
    t.decimal  "ah_point_adjustment"
    t.integer  "customer_id",          :null => false
    t.string   "type",                 :null => false
    t.string   "name",                 :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.string   "name",             :null => false
    t.integer  "billing_cycle_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "efforts", :force => true do |t|
    t.datetime "start",                                 :null => false
    t.datetime "stop"
    t.integer  "duration"
    t.datetime "billed_on"
    t.string   "ticket_reference"
    t.string   "name",                                  :null => false
    t.integer  "contract_id"
    t.integer  "user_id",                               :null => false
    t.integer  "hourly_point_value",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finished",           :default => false
  end

  create_table "rights", :force => true do |t|
    t.string   "name"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer  "right_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                                    :null => false
    t.string   "email",                                   :null => false
    t.integer  "point_value",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
