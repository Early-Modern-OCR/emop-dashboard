ActiveAdmin.register Work do

  permit_params :wks_tcp_number, :wks_estc_number, :wks_tcp_bibno, :wks_marc_record, :wks_eebo_citation_id, :wks_eebo_directory,
                :wks_ecco_number, :wks_book_id, :wks_author, :wks_publisher, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
                :wks_ecco_uncorrected_gale_ocr_path, :wks_ecco_corrected_xml_path, :wks_ecco_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
                :wks_organizational_unit, :wks_primary_print_font

  controller do
    skip_before_filter :get_dropdown_data
  end

  filter :wks_tcp_number
  filter :wks_estc_number

  index do
    id_column
    column :wks_tcp_number
    column :wks_estc_number
    actions
  end
end
