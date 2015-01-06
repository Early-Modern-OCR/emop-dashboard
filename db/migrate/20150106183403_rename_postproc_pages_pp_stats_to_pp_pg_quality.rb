class RenamePostprocPagesPpStatsToPpPgQuality < ActiveRecord::Migration
  def change
    rename_column :postproc_pages, :pp_stats, :pp_pg_quality
  end
end
