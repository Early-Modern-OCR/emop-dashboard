
# Describes a results of a job run on a page
#
class PostprocPage < ActiveRecord::Base
	establish_connection(:emop)
	self.table_name = :postproc_pages
	#belongs_to :page

end