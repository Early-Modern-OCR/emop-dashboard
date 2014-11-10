# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[
  'Not Started',
  'Processing',
  'Pending Postprocess',
  'Postprocessing',
  'Done',
  'Failed',
  'Ingest Failed',
].each do |name|
  JobStatus.find_or_create_by(name: name)
end

[
  'Ground Truth Compare',
  'OCR',
  'Other',
].each do |name|
  JobType.find_or_create_by(name: name)
end

[
  'Gale',
  'Tesseract',
  'Gamera',
  'OCROpus',
  'Not Applicable',
].each do |name|
  OcrEngine.find_or_create_by(name: name)
end

admin = User.find_or_create_by(email: 'admin@internal.local')
if admin.new_record?
  admin.password = 'changeme'
  admin.password_confirmation = 'changeme'
  admin.save!
end
