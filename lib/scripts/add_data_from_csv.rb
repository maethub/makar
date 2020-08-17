# Script to add sample data for a specific schema
# Usage: rails r lib/scripts/add_data.rb <schema_id> <number_of_records>

schema_id = Integer(ARGV.shift)
filename = ARGV.shift
number_of_records = Integer(ARGV.shift) rescue 100
csv = CSV.read(filename, headers: true)

schema = Schema.find(schema_id)

Schema.transaction do

  number_of_records.times do |i|
    record = schema.records.create
    schema.attributes.each do |a|
      puts "#{record.id}: #{a} ==> #{csv[i][a]}"
      record.store_value(a, csv[i][a])
    end
  end
end