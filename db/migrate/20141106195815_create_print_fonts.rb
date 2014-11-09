class CreatePrintFonts < ActiveRecord::Migration
  def change
    create_table :print_fonts, primary_key: :pf_id do |t|
      t.string :pf_name
     end
  end
end
