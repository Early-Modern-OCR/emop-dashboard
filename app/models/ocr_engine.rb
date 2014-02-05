
class OcrEngine < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :ocr_engine
   self.primary_key = :id
   has_many :batch_jobs, foreign_key: 'ocr_engine_id'
end