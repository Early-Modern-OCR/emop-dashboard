class AddSkewIdxToPostprocPages < ActiveRecord::Migration
  def change
    add_column :postproc_pages, :skew_idx, :string
  end
end
