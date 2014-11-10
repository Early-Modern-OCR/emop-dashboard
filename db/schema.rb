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

ActiveRecord::Schema.define(version: 20141106195826) do

  create_table "batch_jobs", force: true do |t|
    t.integer "job_type_id"
    t.integer "ocr_engine_id"
    t.string  "parameters"
    t.string  "name"
    t.string  "notes"
    t.integer "font_id"
  end

  add_index "batch_jobs", ["font_id"], name: "index_batch_jobs_on_font_id", using: :btree
  add_index "batch_jobs", ["job_type_id"], name: "index_batch_jobs_on_job_type_id", using: :btree
  add_index "batch_jobs", ["ocr_engine_id"], name: "index_batch_jobs_on_ocr_engine_id", using: :btree

  create_table "fonts", primary_key: "font_id", force: true do |t|
    t.string  "font_name"
    t.boolean "font_italic"
    t.boolean "font_bold"
    t.boolean "font_fixed"
    t.boolean "font_serif"
    t.boolean "font_fraktur"
    t.integer "font_line_height"
    t.string  "font_library_path"
  end

  create_table "job_queues", force: true do |t|
    t.integer  "batch_id"
    t.integer  "page_id"
    t.integer  "job_status_id"
    t.datetime "created"
    t.datetime "last_update"
    t.string   "results"
    t.integer  "work_id"
    t.string   "proc_id"
    t.integer  "tries",         default: 0
  end

  add_index "job_queues", ["batch_id"], name: "index_job_queues_on_batch_id", using: :btree
  add_index "job_queues", ["job_status_id"], name: "index_job_queues_on_job_status_id", using: :btree
  add_index "job_queues", ["page_id"], name: "index_job_queues_on_page_id", using: :btree
  add_index "job_queues", ["proc_id"], name: "index_job_queues_on_proc_id", using: :btree
  add_index "job_queues", ["work_id"], name: "index_job_queues_on_work_id", using: :btree

  create_table "job_statuses", force: true do |t|
    t.string "name"
  end

  create_table "job_types", force: true do |t|
    t.string "name"
  end

  create_table "juxta_collations", force: true do |t|
    t.integer  "page_result_id"
    t.integer  "jx_gt_source_id"
    t.integer  "jx_ocr_source_id"
    t.integer  "jx_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",            limit: 13, default: "uninitialized"
    t.integer  "jx_gt_witness_id"
    t.integer  "jx_ocr_witness_id"
    t.datetime "last_accessed"
  end

  create_table "ocr_engines", force: true do |t|
    t.string "name"
  end

  create_table "page_results", force: true do |t|
    t.integer  "page_id"
    t.integer  "batch_id"
    t.string   "ocr_text_path"
    t.string   "ocr_xml_path"
    t.datetime "ocr_completed"
    t.float    "juxta_change_index", limit: 24
    t.float    "alt_change_index",   limit: 24
    t.float    "noisiness_idx",      limit: 24
  end

  add_index "page_results", ["batch_id"], name: "index_page_results_on_batch_id", using: :btree
  add_index "page_results", ["page_id"], name: "index_page_results_on_page_id", using: :btree

  create_table "pages", primary_key: "pg_page_id", force: true do |t|
    t.integer "pg_ref_number"
    t.string  "pg_ground_truth_file"
    t.integer "pg_work_id"
    t.string  "pg_gale_ocr_file"
    t.string  "pg_image_path"
  end

  add_index "pages", ["pg_work_id"], name: "index_pages_on_pg_work_id", using: :btree

  create_table "postproc_pages", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "batch_job_id"
    t.float   "pp_ecorr",     limit: 24
    t.float   "pp_juxta",     limit: 24
    t.float   "pp_retas",     limit: 24
    t.float   "pp_health",    limit: 24
    t.float   "pp_stats",     limit: 24
  end

  create_table "print_fonts", primary_key: "pf_id", force: true do |t|
    t.string "pf_name"
  end

  create_table "work_ocr_results", id: false, force: true do |t|
    t.integer  "work_id"
    t.datetime "ocr_completed"
    t.integer  "batch_id"
    t.string   "batch_name"
    t.integer  "ocr_engine_id"
    t.float    "juxta_accuracy", limit: 53
    t.float    "retas_accuracy", limit: 53
  end

  create_table "works", primary_key: "wks_work_id", force: true do |t|
    t.string  "wks_tcp_number"
    t.string  "wks_estc_number"
    t.integer "wks_tcp_bibno"
    t.string  "wks_marc_record"
    t.integer "wks_eebo_citation_id"
    t.string  "wks_eebo_directory"
    t.string  "wks_ecco_number"
    t.integer "wks_book_id"
    t.string  "wks_author"
    t.string  "wks_publisher"
    t.integer "wks_word_count"
    t.text    "wks_title"
    t.string  "wks_eebo_image_id"
    t.string  "wks_eebo_url"
    t.string  "wks_pub_date"
    t.string  "wks_ecco_uncorrected_gale_ocr_path"
    t.string  "wks_ecco_corrected_xml_path"
    t.string  "wks_ecco_corrected_text_path"
    t.string  "wks_ecco_directory"
    t.string  "wks_ecco_gale_ocr_xml_path"
    t.integer "wks_organizational_unit"
    t.integer "wks_primary_print_font"
    t.date    "wks_last_trawled"
  end

  add_index "works", ["wks_book_id"], name: "index_works_on_wks_book_id", using: :btree
  add_index "works", ["wks_ecco_number"], name: "index_works_on_wks_ecco_number", using: :btree

end
