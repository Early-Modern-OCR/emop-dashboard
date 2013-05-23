
# Describes a results of a job run on a page
#
class PageResult < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :page_results
end