class AddWorksCollectionToWorks < ActiveRecord::Migration
  def change
    add_column :works, :collection_id, :integer, index: true
  end
end
