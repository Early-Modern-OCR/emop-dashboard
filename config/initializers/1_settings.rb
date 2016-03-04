class Settings < Settingslogic
  source "#{Rails.root}/config/secrets.yml"
  namespace Rails.env
  load!
end

Settings['project'] ||= 'eMOP'
Settings['font_suffix'] ||= '.traineddata'
Settings['language_model_path'] ||= nil
