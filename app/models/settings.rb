# This used to be a number of settings, until upgrading to Rails 4.1. Now those are in secrets.yml.
class Settings
  def self.auth_token
    return "Basic "+Base64.encode64("#{Rails.application.secrets.juxta_ws_user}:#{Rails.application.secrets.juxta_ws_pass}")
  end
end