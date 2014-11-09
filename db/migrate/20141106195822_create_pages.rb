class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, primary_key: :pg_page_id do |t|
      t.integer :pg_ref_number
      t.string :pg_ground_truth_file
      t.integer :pg_work_id
      t.string :pg_gale_ocr_file
      t.string :pg_image_path
    end

    add_index :pages, :pg_work_id
  end
end
