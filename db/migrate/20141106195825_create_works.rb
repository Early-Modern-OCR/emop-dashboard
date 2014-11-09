class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works, primary_key: :wks_work_id do |t|
      t.string  :wks_tcp_number
      t.string  :wks_estc_number
      t.integer :wks_tcp_bibno
      t.string  :wks_marc_record
      t.integer :wks_eebo_citation_id
      t.string  :wks_eebo_directory
      t.string  :wks_ecco_number
      t.integer :wks_book_id
      t.string  :wks_author
      t.string  :wks_publisher
      t.integer :wks_word_count
      t.text    :wks_title
      t.string  :wks_eebo_image_id
      t.string  :wks_eebo_url
      t.string  :wks_pub_date
      t.string  :wks_ecco_uncorrected_gale_ocr_path
      t.string  :wks_ecco_corrected_xml_path
      t.string  :wks_ecco_corrected_text_path
      t.string  :wks_ecco_directory
      t.string  :wks_ecco_gale_ocr_xml_path
      t.integer :wks_organizational_unit
      t.integer :wks_primary_print_font
      t.date    :wks_last_trawled
    end

    add_index :works, :wks_book_id
    add_index :works, :wks_ecco_number
  end
end
