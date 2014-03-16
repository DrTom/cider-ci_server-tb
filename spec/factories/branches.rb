# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :branch do
    name {Faker::Lorem.words(1).join}
  end
end
