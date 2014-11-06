
# Describes an eMOP work.
#
class Work < ActiveRecord::Base
   establish_connection("emop_#{Rails.env}".to_sym)
   self.table_name = :works
   self.primary_key = :wks_work_id
   has_many :pages, foreign_key: :pg_work_id
   has_many :job_queues, foreign_key: 'work_id'

   def isECCO?
      if !self.wks_ecco_number.nil? && self.wks_ecco_number.length > 0
         return true
      end
      return false
   end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.wks_work_id wks_work_id
        json.wks_tcp_number wks_tcp_number
        json.wks_estc_number wks_estc_number
        json.wks_tcp_bibno wks_tcp_bibno
        json.wks_marc_record wks_marc_record
        json.wks_eebo_citation_id wks_eebo_citation_id
        json.wks_eebo_directory wks_eebo_directory
        json.wks_ecco_number wks_ecco_number
        json.wks_book_id wks_book_id
        json.wks_author wks_author
        json.wks_publisher wks_publisher
        json.wks_word_count wks_word_count
        json.wks_title wks_title
        json.wks_eebo_image_id wks_eebo_image_id
        json.wks_eebo_url wks_eebo_url
        json.wks_pub_date wks_pub_date
        json.wks_ecco_uncorrected_gale_ocr_path wks_ecco_uncorrected_gale_ocr_path
        json.wks_ecco_corrected_xml_path wks_ecco_corrected_xml_path
        json.wks_ecco_corrected_text_path wks_ecco_corrected_text_path
        json.wks_ecco_directory wks_ecco_directory
        json.wks_ecco_gale_ocr_xml_path wks_ecco_gale_ocr_xml_path
        json.wks_organizational_unit wks_organizational_unit
        json.wks_primary_print_font wks_primary_print_font
        json.wks_last_trawled wks_last_trawled
      end
    end
  end
end
