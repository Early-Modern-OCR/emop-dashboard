class ModifyPostprocPages < ActiveRecord::Migration
  def change
    rename_column :postproc_pages, :pp_page_id, :page_id
    rename_column :postproc_pages, :pp_batch_id, :batch_job_id
    add_column :postproc_pages, :id, :primary_key
    add_column :postproc_pages, :noisiness_idx, :float
    add_column :postproc_pages, :multicol, :string
    add_column :postproc_pages, :skew_idx, :string
  end
end
