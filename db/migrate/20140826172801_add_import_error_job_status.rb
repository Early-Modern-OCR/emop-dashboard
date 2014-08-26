class AddImportErrorJobStatus < ActiveRecord::Migration
  def change
     JobQueue.connection.execute('INSERT INTO job_status VALUES( 7, "Ingest Failed" )' )
  end
end
