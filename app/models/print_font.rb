
# Describes an eMOP Print Font (as opposed to training font) 
#
class PrintFont < ActiveRecord::Base
   establish_connection("emop_#{Rails.env}".to_sym)
   self.table_name = :print_fonts
   self.primary_key = :pf_id   
end