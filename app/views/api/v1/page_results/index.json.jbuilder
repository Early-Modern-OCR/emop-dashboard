json.array! @page_results do |page_result|
  json.id page_result.id
  json.ocr_text_path page_result.ocr_text_path
  json.ocr_xml_path page_result.ocr_xml_path
  json.corr_ocr_text_path page_result.corr_ocr_text_path
  json.corr_ocr_xml_path page_result.corr_ocr_xml_path
  json.ocr_completed page_result.ocr_completed
  json.juxta_change_index page_result.juxta_change_index
  json.alt_change_index page_result.alt_change_index
  json.page_id page_result.page_id
  json.batch_id page_result.batch_id
  json.work_id page_result.page.pg_work_id
end
