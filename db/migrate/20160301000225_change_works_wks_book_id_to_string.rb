class ChangeWorksWksBookIdToString < ActiveRecord::Migration
  def change
    change_column :works, :wks_book_id, :string
  end
end
