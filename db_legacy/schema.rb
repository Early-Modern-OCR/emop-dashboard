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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "eebo_word_freq", primary_key: "word", force: true do |t|
    t.integer "frequency", limit: 8, null: false
  end

  add_index "eebo_word_freq", ["frequency"], name: "freq", using: :btree

  create_table "job_lock", primary_key: "jl_job", force: true do |t|
    t.integer  "jl_locked"
    t.integer  "jl_tries"
    t.datetime "jl_last_run"
    t.integer  "jl_works_trawled"
    t.integer  "jl_seconds_run"
    t.string   "jl_parameters"
    t.integer  "jl_run_sequence",  limit: 8
  end

  create_table "job_queue", force: true do |t|
    t.integer   "batch_id",    limit: 8,              null: false
    t.integer   "page_id",     limit: 8,              null: false
    t.integer   "job_status",  limit: 8,  default: 1, null: false
    t.timestamp "created",                            null: false
    t.timestamp "last_update",                        null: false
    t.string    "results"
    t.integer   "work_id"
    t.string    "proc_id",     limit: 20
    t.integer   "tries",                  default: 0
  end

  add_index "job_queue", ["batch_id"], name: "job_queue_ibfk_2", using: :btree
  add_index "job_queue", ["job_status"], name: "job_queue_ibfk_3", using: :btree
  add_index "job_queue", ["page_id"], name: "page_id", using: :btree
  add_index "job_queue", ["proc_id"], name: "proc_id_indx", using: :btree
  add_index "job_queue", ["work_id"], name: "job_queue_ibfk_4", using: :btree

  create_table "job_status", force: true do |t|
    t.string "name", limit: 20
  end

  create_table "job_type", force: true do |t|
    t.string "name", limit: 20
  end

  create_table "ocr_engine", force: true do |t|
    t.string "name", limit: 20
  end

  create_table "page_results", force: true do |t|
    t.integer  "page_id",            limit: 8,   null: false
    t.integer  "batch_id",           limit: 8,   null: false
    t.string   "ocr_text_path",      limit: 200, null: false
    t.string   "ocr_xml_path",       limit: 200, null: false
    t.datetime "ocr_completed",                  null: false
    t.float    "juxta_change_index", limit: 24
    t.float    "alt_change_index",   limit: 24
    t.float    "noisiness_idx",      limit: 53
  end

  add_index "page_results", ["batch_id"], name: "page_results_ibfk_1", using: :btree
  add_index "page_results", ["page_id"], name: "page_id", using: :btree

  create_table "pages", primary_key: "pg_page_id", force: true do |t|
    t.integer "pg_ref_number"
    t.string  "pg_ground_truth_file", limit: 200
    t.integer "pg_work_id"
    t.string  "pg_gale_ocr_file",     limit: 200
    t.string  "pg_image_path",        limit: 200
  end

  add_index "pages", ["pg_work_id"], name: "pages_work_id_index", using: :btree

  create_table "postproc_pages", id: false, force: true do |t|
    t.integer "pp_page_id",  limit: 8,  null: false
    t.integer "pp_batch_id", limit: 8,  null: false
    t.float   "pp_ecorr",    limit: 24
    t.float   "pp_juxta",    limit: 24
    t.float   "pp_retas",    limit: 24
    t.string  "pp_health"
    t.float   "pp_stats",    limit: 24
  end

  create_table "postproc_tagged_pages", id: false, force: true do |t|
    t.integer "ptp_page_id", limit: 8, null: false
    t.integer "ptp_tag_id",            null: false
  end

  create_table "postproc_tags", primary_key: "pt_id", force: true do |t|
    t.string "pt_tag", limit: 100, null: false
  end

  create_table "print_fonts", primary_key: "pf_id", force: true do |t|
    t.string "pf_name", limit: 100
  end

  create_table "table_keys", id: false, force: true do |t|
    t.string  "tk_table", limit: 50
    t.integer "tk_key",   limit: 8
  end

  create_table "trawl", primary_key: "twl_work_id", force: true do |t|
    t.datetime "twl_last_trawled"
    t.string   "twl_source",            limit: 10
    t.string   "twl_error_message"
    t.integer  "twl_gale_doc_ocr_text", limit: 1
    t.integer  "twl_gale_doc_ocr_xml",  limit: 1
    t.integer  "twl_tcp_doc_text",      limit: 1
    t.integer  "twl_tcp_doc_xml",       limit: 1
    t.integer  "twl_images",            limit: 1
    t.integer  "twl_gale_page_text",    limit: 1
    t.integer  "twl_tcp_page_text",     limit: 1
    t.integer  "twl_metadata",          limit: 1
  end

  create_table "work_ocr_results", id: false, force: true do |t|
    t.integer  "work_id"
    t.datetime "ocr_completed",                         null: false
    t.integer  "batch_id",       limit: 8,              null: false
    t.string   "batch_name",     limit: 50,             null: false
    t.integer  "ocr_engine_id",  limit: 8,  default: 4, null: false
    t.float    "juxta_accuracy", limit: 53
    t.float    "retas_accuracy", limit: 53
  end

  create_table "works", primary_key: "wks_work_id", force: true do |t|
    t.string  "wks_tcp_number",                     limit: 45
    t.string  "wks_estc_number",                    limit: 45
    t.integer "wks_tcp_bibno"
    t.string  "wks_marc_record",                    limit: 45
    t.integer "wks_eebo_citation_id"
    t.string  "wks_eebo_directory",                 limit: 100
    t.string  "wks_ecco_number",                    limit: 45
    t.integer "wks_book_id"
    t.string  "wks_author",                         limit: 200
    t.string  "wks_publisher"
    t.integer "wks_word_count"
    t.text    "wks_title"
    t.string  "wks_eebo_image_id",                  limit: 45
    t.string  "wks_eebo_url",                       limit: 200
    t.string  "wks_pub_date",                       limit: 45
    t.string  "wks_ecco_uncorrected_gale_ocr_path", limit: 200
    t.string  "wks_ecco_corrected_xml_path",        limit: 200
    t.string  "wks_ecco_corrected_text_path",       limit: 200
    t.string  "wks_ecco_directory",                 limit: 200
    t.string  "wks_ecco_gale_ocr_xml_path",         limit: 200
    t.integer "wks_organizational_unit"
    t.integer "wks_primary_print_font"
    t.date    "wks_last_trawled"
  end

  add_index "works", ["wks_book_id"], name: "wks_book_id", using: :btree
  add_index "works", ["wks_ecco_number"], name: "wks_ecco_number", using: :btree
  add_index "works", ["wks_work_id"], name: "wks_work_id_UNIQUE", unique: true, using: :btree

  create_table "works_pages", id: false, force: true do |t|
    t.integer "wp_work_id",                              null: false
    t.text    "wp_title"
    t.integer "wp_org_unit"
    t.integer "wp_page_id",      limit: 8,   default: 0, null: false
    t.integer "wp_ref_number"
    t.string  "wp_ground_truth", limit: 200
    t.string  "wp_gale_ocr",     limit: 200
    t.string  "wp_image_path",   limit: 200
  end

end
