# Script to add sample data for a specific schema
# Usage: rails r lib/scripts/add_data.rb <schema_id> <number_of_records>

schema_id = ARGV.shift
number_of_records = Integer(ARGV.shift)

schema = Schema.find(schema_id)

Schema.transaction do
  values = {}
  schema.attributes.each do |a|
    attr_type = schema.attribute_type(a)
    generator = case attr_type
    when 'int'
      ->() { Faker::Number.number(5) }
    when 'string'
      ->() { Faker::Hipster.sentence(2) }
    when 'date'
      ->() { Faker::Date.backward(1000)}
    when 'bool'
      ->() { Faker::Boolean.boolean(0.1)}
    end

    v = []
    number_of_records.times do
      v << generator.call
    end

    values[a] = v
  end

  number_of_records.times do |i|
    record = schema.records.create
    schema.attributes.each do |a|
      puts "#{record.id}: #{a} ==> #{values[a][i]}"
      record.store_value(a, values[a][i])
    end
  end
end