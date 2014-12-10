class RemoveNoisinessIdxFromPageResults < ActiveRecord::Migration
  def change
    remove_column :page_results, :noisiness_idx
  end
end
