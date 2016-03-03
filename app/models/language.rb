class Language < ActiveRecord::Base
  has_many :works

  validates :name, uniqueness: true, presence: true

  def self.ransackable_attributes(auth_object = nil)
    (column_names - ["created_at", "updated_at"]) + _ransackers.keys
  end
end
