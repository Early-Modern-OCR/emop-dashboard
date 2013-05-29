
# Describes OCR accuracy of an eMOP work.
#
class WorkOcrResult < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :work_ocr_results
   self.primary_key = :work_id
end