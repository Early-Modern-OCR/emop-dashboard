class CreateOcrEngines < ActiveRecord::Migration
  def change
    create_table :ocr_engines do |t|
      t.string :name
     end
  end
end
