
# Describes a page from an eMOP work.
#
class Page < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :pages
   self.primary_key = :pg_page_id   
   #has_many :page_results, :foreign_key => :page_id, :order => "ocr_completed desc" 
   
   def get_latest_result( ocr_engine )
      pages = PageResult.where(:page_id => self.id).order("ocr_completed desc")
      pages.each do |page|
         res_ocr = page.get_ocr_engine
         if res_ocr == ocr_engine
            return page
         end
      end
      return  nil
   end
end