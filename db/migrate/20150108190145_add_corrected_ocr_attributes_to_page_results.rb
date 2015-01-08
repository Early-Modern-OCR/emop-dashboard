class AddCorrectedOcrAttributesToPageResults < ActiveRecord::Migration
  def change
    add_column :page_results, :corr_ocr_text_path, :string
    add_column :page_results, :corr_ocr_xml_path, :string
  end
end
