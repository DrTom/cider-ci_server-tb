# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#

all_spec= Specification.find_or_create_by_data! 'substitute_with_path: cider-ci/all_tests.yml'
Definition.find_by(name: "All tests").try(&:destroy)
Definition.create name: "All tests" ,
  description: "Loads the specification from the repository path 'cider-ci/all_tests.yml'.",
  specification: all_spec


executor=Executor.find_or_initialize_by(name: "Localhost")

traits= (executor.traits || []).concat([
          'firefox',
          'imagemagick',
          'jdk',
          'lein',
          'libimage-exiftool-perl',
          'linux',
          'mysql',
          'nodejs',
          'pg93',
          'phantomjs',
          'rbenv',
          'ruby',
          'tightvnc',
        ]).sort.uniq


executor.update_attributes!(
  host: "127.0.0.1",
  port: "8443",
  traits: traits,
  ssl: true
)

executor.save!


ServerSettings.find.update_attributes! \
  repositories_path: Rails.root.join('tmp','repositories').to_s,
  ui_context: 'cider-ci-dev',
  api_context: 'cider-ci-dev'

