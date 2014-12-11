class FixPostprocPagesPpHealthType < ActiveRecord::Migration
  def up
    change_column :postproc_pages, :pp_health, :string
  end

  def down
    change_column :postproc_pages, :pp_health, :float
  end
end
