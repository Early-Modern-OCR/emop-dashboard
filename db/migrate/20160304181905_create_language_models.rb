class CreateLanguageModels < ActiveRecord::Migration
  def change
    create_table :language_models do |t|
      t.string :name
      t.string :path
      t.references :language, index: true

      t.timestamps
    end
    add_index :language_models, :name, unique: true
  end
end
