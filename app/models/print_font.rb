# Describes an eMOP Print Font (as opposed to training font) 
#
class PrintFont < ActiveRecord::Base
  self.primary_key = :pf_id

  validates :pf_name, presence: true 
end
