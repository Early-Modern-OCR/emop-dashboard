class ModifyFontTrainingResults < ActiveRecord::Migration
  def change
    rename_column :font_training_results, :path, :font_path
    add_column :font_training_results, :language_model_path, :string
    add_column :font_training_results, :glyph_substitution_model_path, :string
  end
end
