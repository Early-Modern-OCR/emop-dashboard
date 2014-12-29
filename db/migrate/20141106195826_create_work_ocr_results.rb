class CreateWorkOcrResults < ActiveRecord::Migration
  def self.up
    execute <<-SQL
    CREATE VIEW work_ocr_results AS SELECT
    pages.pg_work_id AS work_id,
    page_results.ocr_completed AS ocr_completed,
    page_results.batch_id AS batch_id,
    batch_jobs.name AS batch_name,
    batch_jobs.ocr_engine_id AS ocr_engine_id,
    avg(page_results.juxta_change_index) AS juxta_accuracy,
    avg(page_results.alt_change_index) AS retas_accuracy
    FROM ((pages JOIN page_results) JOIN batch_jobs) 
    WHERE ((pages.pg_page_id = page_results.page_id) AND (page_results.batch_id = batch_jobs.id)) 
    GROUP BY pages.pg_work_id,page_results.batch_id
    SQL
  end

  def self.down
    execute <<-SQL
    DROP VIEW work_ocr_results
    SQL
  end
end
