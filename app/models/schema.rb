class Schema < ApplicationRecord

  # Associations
  has_many :records, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :schema, presence: true
  validate :schema_is_valid_json
  validate :schema_validation

  # Get Schemas in Collection c
  scope :by_collection, ->(c) { Schema.where(id: Collection.joins(:records).where(id: c.id).pluck(:schema_id).uniq ) }

  # Constants
  SCHEMA_DEFINITION = JSON.parse(File.read('lib/schema_definition.json'))

  def schema_hash
    @schema_hash ||= JSON.parse(schema).with_indifferent_access
  end

  def attribute_type(attribute)
    return nil unless attributes.include?(attribute)
    schema_hash[:attributes].find{ |a| a[:name] ==  attribute}[:type]
  end

  def attributes
    schema_hash[:attributes].map{ |a| a[:name] }
  end

  def multiple?(attribute)
    return nil unless attributes.include?(attribute)
    schema_hash[:attributes].find{ |a| a[:name] ==  attribute}[:multiple] || false
  end

  def input?(attribute)
    return nil unless attributes.include?(attribute)
    schema_hash[:attributes].find{ |a| a[:name] ==  attribute}[:input] || false
  end

  def validate_schema
    # Remove dropped attributes
    RecordValue.from_schema(self).where.not(name: self.attributes).destroy_all

    # Fix types
    self.attributes.each do |a|
      values_to_fix = RecordValue.from_schema(self).where(name: a).where.not(value_type: attribute_type(a))
      values_to_fix.each do |v|
        logger.info "Fixing value #{v.inspect}"
        record = v.record
        record.store_value(v.name, v.data)
      end
    end
  end

  def drop_all_records!
    # record_values
    sql = "DELETE FROM record_values USING records WHERE records.id = record_values.record_id AND records.schema_id = #{id}"
    Record.connection.execute(sql)

    # collection_assignments
    sql = "DELETE FROM collections_records USING records WHERE records.id = collections_records.record_id AND records.schema_id = #{id}"
    Record.connection.execute(sql)

    # records
    sql = "DELETE FROM records WHERE records.schema_id = #{id}"
    Record.connection.execute(sql)
  end

  private

  def schema_is_valid_json
    return if errors.any? # Do not validate schema if errors present
    begin
      JSON.parse!(self.schema)
    rescue JSON::ParserError => e
      errors.add(:schema, "Invalid JSON: #{e.message}")
    end
  end

  # ActiveRecord validation to make sure the schema is valid
  def schema_validation
    return if errors.any? # Do not validate schema if errors present
    begin
      JSON::Validator.validate!(SCHEMA_DEFINITION, self.schema, json: true)
    rescue JSON::Schema::ValidationError => e
      errors.add(:schema, e.message)
    end
  end



end
