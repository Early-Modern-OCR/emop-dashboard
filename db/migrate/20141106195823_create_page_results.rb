class CreatePageResults < ActiveRecord::Migration
  def change
    create_table :page_results do |t|
      t.references :page
      t.references :batch
      t.string :ocr_text_path
      t.string :ocr_xml_path
      t.datetime :ocr_completed
      t.float :juxta_change_index
      t.float :alt_change_index
      t.float :noisiness_idx
    end

    add_index :page_results, :batch_id
    add_index :page_results, :page_id
  end
end
