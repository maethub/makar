require 'rails_helper'
require './spec/data/data_helpers'

RSpec.configure do |c|
  c.include DataHelpers
end

describe Schema, '.new', type: :model do

  it 'does not save without name' do
    schema = Schema.new

    expect(schema.save).to eq false
  end

  it 'does not save without schema' do
    schema = Schema.new(name: 'Test')

    expect(schema.save).to eq false
  end

  it 'does not save without valid schema' do
    schema = Schema.new(name: 'Test', schema: 'some invalid json')

    expect(schema.save).to eq false
  end

  it 'can save simple schema with one int' do
    schema = Schema.new(name: 'Test', schema: load_schema('valid_single_int.json'))
    expect(schema.save).to eq true
  end

  it 'can save simple schema with one string' do
    schema = Schema.new(name: 'Test', schema: load_schema('valid_single_string.json'))
    expect(schema.save).to eq true
  end

  it 'can save simple schema with one date' do
    schema = Schema.new(name: 'Test', schema: load_schema('valid_single_date.json'))
    expect(schema.save).to eq true
  end

  it 'can save simple schema with one bool' do
    schema = Schema.new(name: 'Test', schema: load_schema('valid_single_bool.json'))
    expect(schema.save).to eq true
  end
end
