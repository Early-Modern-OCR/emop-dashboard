
# Describes an eMOP font 
#
class Font < ActiveRecord::Base
  establish_connection("emop_#{Rails.env}".to_sym)
  self.table_name = :fonts
  self.primary_key = :font_id
  has_many :batch_jobs, foreign_key: 'font_id'

  validates :name, presence: true

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.font_id            font_id
        json.font_name          font_name
        json.font_italic        font_italic
        json.font_bold          font_bold
        json.font_fixed         font_fixed
        json.font_serif         font_serif
        json.font_fraktur       font_fraktur
        json.font_line_height   font_line_height
        json.font_library_path  font_library_path
      end
    end
  end
end