Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_RUBY_KEY']
  config.release_stage = ENV['APPLICATION_ENV']
  config.notify_release_stages = ['production', 'staging']
  config.meta_data_filters += ['access_token', 'sso_cert']
end
