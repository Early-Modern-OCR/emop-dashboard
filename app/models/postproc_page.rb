
# Describes a results of a job run on a page
#
class PostprocPage < ActiveRecord::Base
	establish_connection("emop_#{Rails.env}".to_sym)
	self.table_name = :postproc_pages
	#belongs_to :page

end