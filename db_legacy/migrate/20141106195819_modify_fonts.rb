class ModifyFonts < ActiveRecord::Migration
  def change
    rename_column :fonts, :font_id, :id
    rename_column :fonts, :font_name, :name

    [
      'italic',
      'bold',
      'fixed',
      'serif',
      'fraktur',
    ].each do |col|
      rename_column :fonts, "font_#{col}".to_sym, col.to_sym
      change_column :fonts, col.to_sym, :boolean
    end

    rename_column :fonts, :font_line_height, :line_height
    rename_column :fonts, :font_library_path, :library_path
  end
end
