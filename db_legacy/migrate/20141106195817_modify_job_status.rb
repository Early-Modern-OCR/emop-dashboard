class ModifyJobStatus < ActiveRecord::Migration
  def change
    rename_table :job_status, :job_statuses
  end
end
