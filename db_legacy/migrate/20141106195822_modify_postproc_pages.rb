class ModifyPostprocPages < ActiveRecord::Migration
  def change
    rename_column :postproc_pages, :pp_page_id, :page_id
    rename_column :postproc_pages, :pp_batch_id, :batch_job_id
  end
end
