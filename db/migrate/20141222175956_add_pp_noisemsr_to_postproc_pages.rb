class AddPpNoisemsrToPostprocPages < ActiveRecord::Migration
  def change
    add_column :postproc_pages, :pp_noisemsr, :float
  end
end
