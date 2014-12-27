ActiveAdmin.register Work do

  ## Disable new, create, edit, update and destroy
  actions :all, except: [:new, :create, :destroy]

  ## Permit these attributes to be updated
  permit_params :wks_tcp_number, :wks_estc_number, :wks_tcp_bibno, :wks_marc_record, :wks_eebo_citation_id, :wks_eebo_directory,
                :wks_ecco_number, :wks_book_id, :wks_author, :wks_publisher, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
                :wks_ecco_uncorrected_gale_ocr_path, :wks_ecco_corrected_xml_path, :wks_ecco_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
                :wks_organizational_unit, :wks_primary_print_font

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :wks_tcp_number
  filter :wks_estc_number
  filter :wks_ecco_number
  filter :wks_eebo_image_id

  ## INDEX
  index do
    id_column
    column :wks_tcp_number
    column :wks_estc_number
    column :wks_ecco_number
    column :wks_eebo_image_id
    actions
  end
end
