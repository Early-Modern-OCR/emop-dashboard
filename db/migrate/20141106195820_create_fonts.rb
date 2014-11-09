class CreateFonts < ActiveRecord::Migration
  def change
    create_table :fonts, primary_key: :font_id do |t|
      t.string :font_name
      t.boolean :font_italic
      t.boolean :font_bold
      t.boolean :font_fixed
      t.boolean :font_serif
      t.boolean :font_fraktur
      t.integer :font_line_height
      t.string :font_library_path
    end
  end
end
