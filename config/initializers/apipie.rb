Apipie.configure do |config|
  config.app_name                = "Czardom"
  config.default_version         = 'v1'
  config.api_base_url['v1']        = ''
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/.rb"
  config.validate = false
  config.default_version = 'public'
  config.default_locale = 'en'
end
