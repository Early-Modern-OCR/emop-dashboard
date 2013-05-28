
# Describes a page from an eMOP work.
#
class Page < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :pages
   self.primary_key = :pg_page_id   
   has_many :page_results, :foreign_key => :page_id, :order => "ocr_completed desc" 
end