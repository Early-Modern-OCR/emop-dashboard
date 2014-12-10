class AddNoisinessIdxToPostProcPages < ActiveRecord::Migration
  def change
    add_column :postproc_pages, :noisiness_idx, :float
  end
end
