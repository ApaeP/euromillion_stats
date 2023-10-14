ActiveRecord::Schema.define(version: 2023_10_14_101753) do
  enable_extension "plpgsql"

  create_table "draws", force: :cascade do |t|
    t.date "date"
    t.integer "number1"
    t.integer "number2"
    t.integer "number3"
    t.integer "number4"
    t.integer "number5"
    t.integer "star1"
    t.integer "star2"
    t.integer "won_by"
    t.string "prize"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
