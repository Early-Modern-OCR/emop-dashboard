
# Describes GALE accuracy of an eMOP work.
#
class WorkGaleResult < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :work_gale_results
   self.primary_key = :work_id
end