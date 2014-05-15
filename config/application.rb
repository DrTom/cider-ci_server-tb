require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# fixes an issue with Oracles java, jruby and encrypted cookies 
if RUBY_PLATFORM == "java"
  # jce_class.getDeclaredField("isRestricted") will throw an exception 
  # on the free java implementation; but we don't to patch it there anyways
  begin  
    jce_class =  java::lang::Class.forName("javax.crypto.JceSecurity")
    field = jce_class.getDeclaredField("isRestricted")
    field.setAccessible(true)
    field.set(nil,false)
  rescue Exception => e
  end
end

module CiderCI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    config.autoload_paths += \
      %w(lib services).map{|dir| Rails.root.join("app",dir)} 

    config.active_record.schema_format = :sql

    config.generators.helper = false
    config.generators.javascripts = false
    config.generators.stylesheets = false

    config.generators.view_specs= false
    config.generators.helper_specs = false

    config.active_record.timestamped_migrations = false

    config.log_tags = [:port, :remote_ip, lambda{|req| Time.now.strftime("%T")} ]

    config.action_controller.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT'] or ''

    if defined?(Torquebox)  
      config.cache_store = :torquebox_store, {expires_in: (60*60*24*7)}
    else
      config.cache_store = :memory_store
    end

    config.release_info = YAML.load_file(Rails.root.join "config","release.yml")
      .with_indifferent_access[:release]

  end
end
