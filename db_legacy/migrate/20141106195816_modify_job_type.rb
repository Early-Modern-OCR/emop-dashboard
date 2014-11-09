class ModifyJobType < ActiveRecord::Migration
  def change
    rename_table :job_type, :job_types
  end
end
