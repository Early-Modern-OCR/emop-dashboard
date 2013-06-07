class JuxtaCollation < ActiveRecord::Base
   attr_accessible :page_result_id, :jx_gt_source_id, :jx_ocr_source_id, :jx_set_id, :status 
   
   validates_inclusion_of :status, :in => ['uninitialized', 'ready', 'error', :uninitialized, :ready, :error]
end
