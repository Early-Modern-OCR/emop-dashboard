class AddMulticolToPostprocPages < ActiveRecord::Migration
  def change
    add_column :postproc_pages, :multicol, :string
  end
end
