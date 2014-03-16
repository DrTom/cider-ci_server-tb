#!/usr/bin/env ruby
require 'yaml'
require 'securerandom'

raise "env CI_TRIAL_ID must be set" unless ENV['CI_TRIAL_ID'] 
raise "env CI_EXECUTION_ID must be set" unless ENV['CI_EXECUTION_ID'] 

def trial_id
  @_trial_id ||= ENV['CI_TRIAL_ID'][0..7]
end

def execution_id
  @_execution_id ||= ENV['CI_EXECUTION_ID'][0..7]
end

config = YAML.load_file("config/database_cider-ci.yml")
config["test"]["database"] = %Q[#{config["test"]["database"]}_#{trial_id}]

File.delete "config/database.yml" rescue nil
File.open("config/database.yml",'w'){|f| f.write(config.to_yaml)}
