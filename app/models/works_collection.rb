class WorksCollection < ActiveRecord::Base
  has_many :works

  validates :name, uniqueness: true, presence: true
end
