# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined?  TorqueBox
  run Rails.application
else
  raise "RAILS_RELATIVE_URL_ROOT env variable must be set" unless ENV['RAILS_RELATIVE_URL_ROOT']
  map Rails.application.config.relative_url_root do
    run Rails.application
  end
end
