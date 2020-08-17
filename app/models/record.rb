class Record < ApplicationRecord
  has_many :record_values, dependent: :delete_all
  has_and_belongs_to_many :collections
  belongs_to :schema

  scope :active, ->() { where(deactivated: false) }

  delegate :attributes, :multiple?, to: :schema

  def self.bulk_cache
    @bulk_cache ||= []
  end

  def self.import_bulk
    RecordValue.import bulk_cache, validate: false
    @bulk_cache = [] # Reset cache
  end

  def value?(name)
    schema.attributes.include?(name)
  end

  def value(name)
    return nil unless value?(name)
    record_values.where(name: name).first
  end

  def to_h(attributes = schema.attributes)
    attributes.each { |a| fetch_value(a) }
    value_cache.to_h
  end

  def inspect
    to_h.collect{ |k,v| v.is_a?(String) ? [k, v.truncate(200)] : [k,v] }.to_h
  end

  def value_cache
    @value_cache ||= OpenStruct.new
  end

  def store_value(name, *arguments)
    return nil unless value?(name)
    if self.multiple?(name)
      values = []
      if arguments.first.respond_to?(:each)
        # Argument is iterable --> replace all values
        arguments.first.each_with_index do |v, i|
          value = check_type(name, v)
          upsert_value(name, value, i)
          values << value
        end
        record_values.with_name(name).where('index > ?', arguments.first.count).destroy_all
      end
      value_cache[name] = values
      return values
    else
      value = check_type(name, arguments.first)
      upsert_value(name, value)
      value_cache[name] = value
      return value
    end
  end

  def bulk_store_value(name, *arguments)
    return nil unless value?(name)
    if self.multiple?(name)
      values = []
      if arguments.first.respond_to?(:each)
        # Argument is iterable --> replace all values
        arguments.first.each_with_index do |v, i|
          value = check_type(name, v)
          Record.bulk_cache << bulk_value(name, value, i)
          values << value
        end
        record_values.with_name(name).where('index > ?', arguments.first.count).destroy_all
      end
      value_cache[name] = values
      return values
    else
      value = check_type(name, arguments.first)
      Record.bulk_cache << bulk_value(name, value)
      value_cache[name] = value
      return value
    end
  end

  def fetch_value(name, *arguments)
    return value_cache[name] if value_cache[name] # Try to get from cache
    return nil unless value?(name)
    load_value_from_db(name)
  end

  # Redirect methods that correspond to getter and setter of valid attributes
  def method_missing(method_name, *arguments, &block)
    method_name_s = method_name.to_s
    if attributes.include?(method_name_s.gsub('=', ''))
      if method_name_s =~ /^(.*)=$/
        store_value(method_name_s.gsub('=', ''), *arguments)
      else
        fetch_value(method_name_s)
      end
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    attributes.include?(method_name.to_s.gsub('=', '')) || super
  end

  private

  # Load value from DB and safe to cache
  # UNSAFE: does not check whether attribute exists!
  def load_value_from_db(name)
    if self.multiple?(name)
      return value_cache[name] = self.record_values.where(name: name).collect(&:data)
    else
      return value_cache[name] = self.record_values.where(name: name).first.try(:data)
    end
  end

  TYPE_ASSIGNMENT = { 'int': [Integer], 'string': [String], 'bool': [TrueClass, FalseClass], 'date': [Date], 'html': [String]}.freeze
  def check_type(attribute, value)
    t = schema.attribute_type(attribute)
    return value if TYPE_ASSIGNMENT[t.to_sym].include?(value.class)
    begin
      case t
      when 'int'
        value = Integer(value)
      when 'string', 'html'
        value = value.to_s
      when 'bool'
        value = ActiveModel::Type::Boolean.new.cast(value)
      when 'date'
        value = (value.is_a?(String) ? Date.parse(value) : value&.to_date)
      else
        fail "Type #{t} is invalid!"
      end
    rescue StandardError => e
      fail "Cannot cast value #{value} to type #{t}!"
    end
    value
  end

  def upsert_value(name, value, index = 0)
    RecordValue.new(
        record_id: self.id,
        name: name,
        index: index,
        data: value,
        value_type: schema.attribute_type(name)
    ).upsert
  end

  def bulk_value(name, value, index = 0)
    {
      record_id: self.id,
      name: name,
      index: index,
      data: value,
      value_type: schema.attribute_type(name)
    }
  end


end
