module FactoryHelpers
  def self.load_schema(name)
    File.read('./spec/data/schemas/' + name)
  end
end


FactoryBot.define do

  factory :schema do
    name { "TestSchema" }
    schema { FactoryHelpers::load_schema('valid_complex_1.json')}
  end

  factory :record do
    association :schema, factory: :schema
  end

end