class AddLanguageModelToBatchJob < ActiveRecord::Migration
  def change
    add_column :batch_jobs, :language_model_id, :integer, index: true
  end
end
