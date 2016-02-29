class RenameWorksColumns < ActiveRecord::Migration
  def change
    rename_column :works, :wks_eebo_directory, :wks_doc_directory
    rename_column :works, :wks_publisher, :wks_printer
    rename_column :works, :wks_ecco_corrected_xml_path, :wks_corrected_xml_path
    rename_column :works, :wks_ecco_corrected_text_path, :wks_corrected_text_path
    rename_column :works, :wks_tcp_number, :wks_gt_number
    rename_column :works, :wks_bib_name, :wks_coll_name
  end
end
