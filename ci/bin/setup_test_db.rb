#!/usr/bin/env ruby
require 'yaml'

$LOAD_PATH << './cider_ci/lib'
require 'cider_ci/database'


config = YAML.load_file("config/database.yml")["test"]
CiderCI::Database.create_db config
CiderCI::System.execute_cmd! "cat db/structure.sql | psql "
