Apipie.configure do |config|
  config.app_name                 = "eMOP Dashboard"
  config.api_base_url             = "/api"
  config.doc_base_url             = "/apidoc"
  config.api_controllers_matcher  = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version          = "v1"
  config.markup                   = Apipie::Markup::Markdown.new if Rails.env.development? and defined? Maruku
  config.show_all_examples        = true
end
