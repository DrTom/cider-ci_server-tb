# Read about factories at https://github.com/thoughtbot/factory_girl

require Rails.root.join 'lib','data_factory.rb'

FactoryGirl.define do

  factory :rspec_specification, aliases: [:specification], class: Specification do
    data {DataFactory.rspec_specification_data}
  end

  factory :show_env_specification, class: Specification do
    data {DataFactory.show_env_specification}
  end

end
