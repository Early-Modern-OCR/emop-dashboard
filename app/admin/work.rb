ActiveAdmin.register Work do

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
  filter :language
  filter :wks_title
  filter :wks_printer
  filter :wks_gt_number
  filter :wks_book_id

  ## INDEX
  index do
    column :id do |work|
      link_to work.id, admin_work_path(work)
    end
    column :collection
    column :language
    column :wks_title
    column :wks_book_id
    column :wks_printer
    column :wks_gt_number
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row('Collection') do
        work.collection.name if work.collection.present?
      end
      row('Language') do
        work.language.name if work.language.present?
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

  ## NEW / EDIT
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :collection
      f.input :language
      f.input :print_font
      f.input :wks_gt_number
      f.input :wks_estc_number
      f.input :wks_coll_name
      f.input :wks_tcp_bibno
      f.input :wks_marc_record
      f.input :wks_eebo_citation_id
      f.input :wks_doc_directory
      f.input :wks_ecco_number
      f.input :wks_book_id
      f.input :wks_author
      f.input :wks_printer
      f.input :wks_word_count
      f.input :wks_title
      f.input :wks_eebo_image_id
      f.input :wks_eebo_url
      f.input :wks_pub_date
      f.input :wks_ecco_uncorrected_gale_ocr_path
      f.input :wks_corrected_xml_path
      f.input :wks_corrected_text_path
      f.input :wks_ecco_directory
      f.input :wks_ecco_gale_ocr_xml_path
      f.input :wks_organizational_unit
    end
    f.actions
  end
end
