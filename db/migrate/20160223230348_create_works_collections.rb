class CreateWorksCollections < ActiveRecord::Migration
  def change
    create_table :works_collections do |t|
      t.string :name

      t.timestamps
    end
  end
end
