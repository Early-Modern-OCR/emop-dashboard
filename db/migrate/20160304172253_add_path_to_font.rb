class AddPathToFont < ActiveRecord::Migration
  def change
    add_column :fonts, :path, :string
  end
end
