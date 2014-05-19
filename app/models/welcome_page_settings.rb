class WelcomePageSettings < ActiveRecord::Base
  include Concerns::Settings

  serialize :radiator_config
end
