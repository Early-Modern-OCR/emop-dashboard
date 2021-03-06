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

FactoryGirl.register_strategy(:json, JsonStrategy)

FactoryGirl.define do
  factory :ocr_engine do
    name "Tesseract"
  end

  factory :job_type do
    name "OCR"
  end

  factory :print_font do
    sequence(:pf_name) { |n| "Test Training Suite-#{n}" }
  end

  factory :font do
    font_name         "baskerville"
    font_library_path "/data/shared/fonts/baskerville/emop.traineddata"
  end

  factory :works_collection do
    sequence(:name) { |n| "collection-#{n}" }
  end

  factory :language do
    sequence(:name) { |n| "language-#{n}" }
  end

  factory :language_model do
    sequence(:name) { |n| "language-model-#{n}" }
    sequence(:path) { |n| "/dne/language-model-#{n}" }
    language { FactoryGirl.build(:language) }
  end

  factory :glyph_substitution_model do
    sequence(:name) { |n| "glyph_substitution_model-#{n}" }
    sequence(:path) { |n| "/dne/glyph_substitution_model-#{n}" }
  end

  factory :font_training_result do
    sequence(:font_path) { |n| "/dne/font-#{n}" }
    sequence(:language_model_path) { |n| "/dne/lm-#{n}" }
    sequence(:glyph_substitution_model_path) { |n| "/dne/gsm-#{n}" }
    work { FactoryGirl.build(:work) }
    batch_job { FactoryGirl.build(:batch_job) }
  end

  factory :work do
    wks_estc_number "T137595"
    wks_ecco_number "0212100100"
    wks_author "Baskerville, John"
    wks_printer "Birmingham : printed by John Baskerville, and sold by Messieurs Dod, Rivington, Longman, Richardson, Hawes and Co. Crowder, Robson, and Stuart, London, 1765 [1766]."
    sequence(:wks_title) { |n| "Title-#{n}" }
    wks_pub_date "1765"
    wks_ecco_directory "/data/ecco/ECCO_2of2/LitAndLang_1/0212100100/images"
    wks_ecco_gale_ocr_xml_path "/data/ecco/ECCO_2of2/LitAndLang_1/0212100100/xml/0212100100.xml"
    wks_organizational_unit 265
    wks_last_trawled "2013-06-30"

    before(:create) do |work|
      work.pages << build(:page, work: work)
    end
  end

  factory :page do
    sequence(:pg_ref_number) { |n| n }
    sequence(:pg_image_path) { |n| "/data/ecco/somepath-#{n}" }
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
    corr_ocr_text_path '/some/path/output_ALTO.txt'
    corr_ocr_xml_path '/some/path/output_ALTO.xml'
    ocr_completed Time.parse("Nov 09 2014")
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
    pp_pg_quality 0.0
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
