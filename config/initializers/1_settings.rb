class Settings < Settingslogic
  source "#{Rails.root}/config/secrets.yml"
  namespace Rails.env
  load!
end

Settings['project'] ||= 'eMOP'

