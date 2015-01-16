# Initialize everything about email addresses and sending

[
  'address',
  'port',
  'domain',
  'user_name',
  'password',
  'authentication',
  'enable_starttls_auto',
].each do |setting|
  value = Rails.application.secrets.smtp_settings[setting]
  if value.present?
    ActionMailer::Base.smtp_settings[setting.to_sym] = value
  end
end

ActionMailer::Base.default_url_options[:host] = Rails.application.secrets.smtp_settings['return_path']

# This is for sendgrid: it helps with the statistics on the sendgrid site.
if Rails.application.secrets.smtp_settings['xsmtpapi'].present?
	ActionMailer::Base.default "X-SMTPAPI" => "{\"category\": \"#{Rails.application.secrets.smtp_settings['xsmtpapi']}\"}"
end
