class WorksCollection < ActiveRecord::Base
  has_many :works

  validates :name, uniqueness: true, presence: true

  def to_builder(version = 'v2')
    case version
    when 'v2'
      Jbuilder.new do |json|
        json.(self, :id, :name)
      end
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    (column_names - ["created_at", "updated_at"]) + _ransackers.keys
  end

end
