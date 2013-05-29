
# Describes an eMOP work.
#
class Work < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :works
   self.primary_key = :wks_work_id
   has_many :pages, :foreign_key => :pg_work_id
   has_one :work_ocr_result
   has_one :work_gale_result

   def isECCO?
      if !self.wks_ecco_number.nil? && self.wks_ecco_number.length > 0
         return true
      end
      return false
   end
end