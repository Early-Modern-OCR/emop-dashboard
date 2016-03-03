class AddLanguageIdToWorks < ActiveRecord::Migration
  def change
    add_column :works, :language_id, :integer, index: true
  end
end
