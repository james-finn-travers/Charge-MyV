FactoryBot.define do
  factory :charging_station do
    sequence(:name) { |n| "Charging Station #{n}" }
    sequence(:address) { |n| "#{n} Yonge St, Toronto, ON" }
    sequence(:latitude) { |n| (43.6532 + (n * 0.001)).round(6) }
    sequence(:longitude) { |n| (-79.3832 - (n * 0.001)).round(6) }
    power_output { 50.0 }
    connector_types { "CCS, Type 2" }
    is_operational { true }
  end
end
