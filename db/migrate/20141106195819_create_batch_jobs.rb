class CreateBatchJobs < ActiveRecord::Migration
  def change
    create_table :batch_jobs do |t|
      t.string :parameters
      t.string :name
      t.string :notes
      t.references :font
      t.references :ocr_engine
      t.references :job_type
    end

    add_index :batch_jobs, :job_type_id
    add_index :batch_jobs, :ocr_engine_id
    add_index :batch_jobs, :font_id
  end
end
