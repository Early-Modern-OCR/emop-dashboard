class CreateGlyphSubstitutionModels < ActiveRecord::Migration
  def change
    create_table :glyph_substitution_models do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
