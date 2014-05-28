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



repo= Repository.find_or_initialize_by name: "Cider-CI Bash Demo Project"
repo.update_attributes! \
  origin_uri: 'https://github.com/DrTom/cider-ci_demo-project-bash.git'


welcome_page_settings= WelcomePageSettings.find

if welcome_page_settings.welcome_message.blank? 
  welcome_page_settings.update_attributes! \
    welcome_message: "# Welcome to your installation of Cider-CI"
end
  
if welcome_page_settings.radiator_config.blank? 
  welcome_page_settings.update_attributes! \
    radiator_config:  YAML.load(%<---
      rows: 
      - name: Bash Demo Project
        items: 
        - repository_name: "Cider-CI Bash Demo Project"
          branch_name: "master"
          definition_name: "All tests"
    >)

end
  




