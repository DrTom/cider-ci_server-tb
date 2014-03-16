# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#

all_spec= Specification.find_or_create_by_data! 'substitute_with_path: ci/all_tests.yml'
Definition.find_by(name: "All tests").try(&:destroy)
Definition.create name: "All tests" ,
  description: "Loads the specification from the repository path 'ci/all_tests.yml'.",
  specification: all_spec



