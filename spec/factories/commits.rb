# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commit do
    id { Digest::SHA1.hexdigest(rand.to_s) }
    tree_id {Digest::SHA1.hexdigest(rand.to_s)}
  end
end
