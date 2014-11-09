class CreatePostprocPages < ActiveRecord::Migration
  def change
    create_table :postproc_pages, id: false do |t|
      t.references :page
      t.references :batch_job
      t.float :pp_ecorr
      t.float :pp_juxta
      t.float :pp_retas
      t.float :pp_health
      t.float :pp_stats
    end
  end
end
