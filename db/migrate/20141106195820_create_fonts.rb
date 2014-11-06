class CreateFonts < ActiveRecord::Migration
  def change
    create_table :fonts do |t|
      t.string :name
      t.boolean :italic
      t.boolean :bold
      t.boolean :fixed
      t.boolean :serif
      t.boolean :fraktur
      t.integer :line_height
      t.string :library_path

      t.timestamps
    end
  end
end
