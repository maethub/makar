require 'rails_helper'
require './spec/data/data_helpers'

RSpec.configure do |c|
  c.include DataHelpers
end

describe Record, type: :model do

  describe '.new' do

    before(:all) do
      @schema = create(:schema)
    end

    it 'does not save without a schema' do
      record = Record.new

      expect(record.save).to eq false
    end

    it 'does save with a schema' do
      record = Record.new(schema: @schema)

      expect(record.save).to eq true
    end
  end

  # Setup record
  before(:all) do
    @record = create(:record)
  end

  describe '#value?' do

    it 'does recognize valid attribute' do
      expect(@record.value?('supercar')).to eq true
    end

    it 'does not recognize invalid attribute' do
      expect(@record.value?('notdefined attribute')).to eq false
    end
  end

  describe '#attributes' do

    it 'returns all defined attributes of the schema' do
      attributes = @record.attributes

      expect(attributes).to include('id', 'name', 'supercar', 'creation_date')
    end
  end
end
