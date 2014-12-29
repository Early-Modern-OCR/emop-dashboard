def create_attributes(*args)
  FactoryGirl.create(*args).attributes.delete_if do |k, v|
    ["id", "created_at", "updated_at", "ocr_completed", nil].member?(k)
  end
end

def build_attributes(*args)
  FactoryGirl.build(*args).attributes.delete_if do |k, v|
    ["id", "created_at", "updated_at", "ocr_completed", nil].member?(k)
  end
end

FactoryGirl.define do
  factory :ocr_engine do
    name "Tesseract"
  end

  factory :job_type do
    name "OCR"
  end

  factory :print_font do
    pf_name "Test Training Suite-ECCO"
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

  factory :page do
    pg_ref_number 1
    pg_image_path "/data/ecco/somepath"
    work { FactoryGirl.build(:work) }
  end

  factory :job_status do
    name 'Not Started'

    factory :processing do
      name 'Processing'
    end
    factory :pending_postproc do
      name 'Pending Postprocess'
    end
    factory :postprocessing do
      name 'Postprocessing'
    end
    factory :done do
      name 'Done'
    end
    factory :failed do
      name 'Failed'
    end
    factory :ingest_failed do
      name 'Ingest Failed'
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
    batch_job { FactoryGirl.build(:batch_job) }
    status    { JobStatus.first }
    page      { FactoryGirl.build(:page) }
    work      { FactoryGirl.build(:work) }
  end

  factory :page_result do
    page { FactoryGirl.build(:page) }
    batch_job { FactoryGirl.build(:batch_job) }
    ocr_text_path '/some/path/output.txt'
    ocr_xml_path  '/some/path/output.xml'
    juxta_change_index 0.0
    alt_change_index 0.0

    #after(:create) do |p|
    #  p.page = create(:page)
    #  p.batch_job = create(:batch_job)
    #end
  end

  factory :postproc_page do
    page { FactoryGirl.build(:page) }
    batch_job { FactoryGirl.build(:batch_job) }
    pp_noisemsr 0.0
    pp_ecorr 0.0
    pp_juxta 0.0
    pp_retas 0.0
    pp_health '{"total":365,"ignored":22,"correct":119,"corrected":40,"unchanged":184}'
    pp_stats 0.0
    noisiness_idx 0.0
    multicol '0;1;2'
    skew_idx '1;0;1'

    #after(:create) do |p|
    #  p.page = create(:page)
    #  p.batch_job = create(:batch_job)
    #end
  end

  factory :user do
    email "admin@example.com"
    password "changeme"
    password_confirmation "changeme"
  end
end
