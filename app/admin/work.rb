ActiveAdmin.register Work do

  ## Disable new, create, edit, update and destroy
  actions :all, except: [:new, :create, :destroy]

  ## Permit these attributes to be updated
  permit_params :wks_gt_number, :wks_estc_number, :wks_coll_name, :wks_tcp_bibno, :wks_marc_record, :wks_eebo_citation_id, :wks_doc_directory,
                :wks_ecco_number, :wks_book_id, :wks_author, :wks_printer, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
                :wks_ecco_uncorrected_gale_ocr_path, :wks_corrected_xml_path, :wks_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
                :wks_organizational_unit, :wks_primary_print_font, :collection_id

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :wks_work_id, label: 'ID'
  filter :collection
  filter :wks_gt_number
  filter :wks_estc_number
  filter :wks_ecco_number
  filter :wks_eebo_image_id

  ## INDEX
  index do
    column :id do |work|
      link_to work.id, admin_work_path(work)
    end
    column :collection
    column :wks_gt_number
    column :wks_estc_number
    column :wks_ecco_number
    column :wks_eebo_image_id
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row('Collection') do
        work.collection.name if work.collection.present?
      end
      row('GT Number') { |w| w.wks_gt_number }
      row('ESTC Number') { |w| w.wks_estc_number }
      row('Coll Name') { |w| w.wks_coll_name }
      row('TCP Bibno') { |w| w.wks_tcp_bibno }
      row('MARC Record') { |w| w.wks_marc_record }
      row('EEBO Citation ID') { |w| w.wks_eebo_citation_id }
      row('Doc Directory') { |w| w.wks_doc_directory }
      row('ECCO Number') { |w| w.wks_ecco_number }
      row('Book ID') { |w| w.wks_book_id }
      row('Author') { |w| w.wks_author }
      row('Printer') { |w| w.wks_printer }
      row('Word Count') { |w| w.wks_word_count }
      row('Title') { |w| w.wks_title }
      row('EEBO Image ID') { |w| w.wks_eebo_image_id }
      row('EEBO URL') { |w| w.wks_eebo_url }
      row('Pub Date') { |w| w.wks_pub_date }
      row('ECCO Uncorrected Gale OCR Path') { |w| w.wks_ecco_uncorrected_gale_ocr_path }
      row('Corrected XML Path') { |w| w.wks_corrected_xml_path }
      row('Corrected Text Path') { |w| w.wks_corrected_text_path }
      row('ECCO Directory') { |w| w.wks_ecco_directory }
      row('ECCO Gale OCR XML Path') { |w| w.wks_ecco_gale_ocr_xml_path }
      row('Organizational Unit') { |w| w.wks_organizational_unit }
      row('Primary Print Font') { |w| w.wks_primary_print_font } #TODO link to Admin PrintFont page
    end

    panel "Pages" do
      pages = work.pages
      paginated_collection(pages.page(params[:page]).per(15), download_links: false) do
        table_for collection do
          column :id do |p|
            link_to p.id, admin_page_path(p)
          end
          column :pg_ref_number
        end
      end
    end
  end
end
