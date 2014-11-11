class AddPrimaryKeyToPostprocPages < ActiveRecord::Migration
  def change
    add_column :postproc_pages, :id, :primary_key
  end
end
