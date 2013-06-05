require 'settingslogic'

# settingsLogic model to expose settings from emop.yml
# to the eMOP dashboard app
#
class Settings < Settingslogic
  source "#{Rails.root}/config/emop.yml"
  namespace Rails.env
  load!
end