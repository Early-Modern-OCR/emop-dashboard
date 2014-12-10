# Describes an eMOP Print Font (as opposed to training font) 
#
class PrintFont < ActiveRecord::Base
  self.primary_key = :pf_id

  validates :pf_name, presence: true

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.id   id
        json.name name
      end
    end
  end

  #TODO: Remove once schema is sane
  def id
    read_attribute(:pf_id)
  end

  #TODO: Remove once schema is sane
  def name
    read_attribute(:pf_name)
  end
end
