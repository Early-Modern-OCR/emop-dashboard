class ModifyOcrEngine < ActiveRecord::Migration
  def change
    rename_table :ocr_engine, :ocr_engines
  end
end
