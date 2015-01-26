json.array! @postproc_pages do |postproc_page|
  json.id postproc_page.id
  json.pp_noisemsr postproc_page.pp_noisemsr
  json.pp_ecorr postproc_page.pp_ecorr
  json.pp_juxta postproc_page.pp_juxta
  json.pp_retas postproc_page.pp_retas
  json.pp_health postproc_page.pp_health
  json.pp_pg_quality postproc_page.pp_pg_quality
  json.noisiness_idx postproc_page.noisiness_idx
  json.multicol postproc_page.multicol
  json.skew_idx postproc_page.skew_idx
  json.page_id postproc_page.page_id
  json.batch_job_id postproc_page.batch_job_id
end
