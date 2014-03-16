# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :executor do
    host {Faker::Internet.ip_v4_address}
    port {rand(2**16)}
    name {Faker::Name.last_name}
    traits (["linux","ruby","rbenv","ruby-2.0.0","postgresql"])
    last_ping_at {Time.zone.now}
  end
end
