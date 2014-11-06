FactoryGirl.define do
  factory :page do
    pg_ref_number 1
    pg_image_path "/data/ecco/somepath"
  end

  factory :ocr_engine do
    name "Tesseract"
  end

  factory :job_type do
    name "OCR"
  end

  factory :font do
    font_name         "baskerville"
    font_library_path "/data/shared/fonts/baskerville/emop.traineddata"
  end

  factory :work do
    wks_estc_number "T137595"
    wks_ecco_number "0212100100"
    wks_author "Baskerville, John"
    wks_publisher "Birmingham : printed by John Baskerville, and sold by Messieurs Dod, Rivington, Longman, Richardson, Hawes and Co. Crowder, Robson, and Stuart, London, 1765 [1766]."
    wks_title "A vocabulary, or pocket dictionary. To which is prefixed, a compendious grammar of the English language."
    wks_pub_date "1765"
    wks_ecco_directory "/data/ecco/ECCO_2of2/LitAndLang_1/0212100100/images"
    wks_ecco_gale_ocr_xml_path "/data/ecco/ECCO_2of2/LitAndLang_1/0212100100/xml/0212100100.xml"
    wks_organizational_unit 265
    wks_last_trawled "2013-06-30"
  end

  factory :job_status do
    name  'Not Started'

    factory :processing do
      name 'Processing'
    end
  end

  factory :batch_job do
    name        "OCR Test"
    parameters  ""
    notes       "test"
    job_type    { FactoryGirl.build(:job_type) }
    ocr_engine  { FactoryGirl.build(:ocr_engine) }
    font        { FactoryGirl.build(:font) }
  end

  factory :job_queue do
    tries     0
    results   "Foo"
    batch_job { FactoryGirl.build(:batch_job) }
    status    { FactoryGirl.build(:job_status) }
    page      { FactoryGirl.build(:page) }
    work      { FactoryGirl.build(:work) }
  end
end
