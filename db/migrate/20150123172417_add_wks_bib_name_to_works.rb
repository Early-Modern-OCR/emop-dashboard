class AddWksBibNameToWorks < ActiveRecord::Migration
  def change
    add_column :works, :wks_bib_name, :string, after: :wks_estc_number
  end
end
