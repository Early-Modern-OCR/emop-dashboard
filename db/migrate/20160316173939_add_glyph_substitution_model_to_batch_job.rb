class AddGlyphSubstitutionModelToBatchJob < ActiveRecord::Migration
  def change
    add_column :batch_jobs, :glyph_substitution_model_id, :integer, index: true
  end
end
