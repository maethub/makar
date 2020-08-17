class Transformation::ExtractValueTransformation < Transformation

  DESCRIPTION = 'Extract the values from :in_attributes and creates new Records of Schema :schema'

  INPUTS      = {
    in_attribute: :string,
    collection: :collection,
    schema: :schema,
    out_attribute: :string,
    allow_duplicates: :bool
  }.freeze

  def init
    # Do nothing
    @hash = {}
  end

  def transform!
    @collection.records.each do |r|
      val = r.fetch_value(@in_attribute.to_s)
      if val.respond_to?(:each) && !@schema.multiple?(@out_attribute)
        # Make multiple --> single
        val.each do |v|
          save_value v
        end
      else
        save_value val
      end
    end
  end

  def save_value(value)
    return if !@allow_duplicates && @hash.has_key?(value.to_s)
    @hash[value.to_s] = true
    to_record = @schema.records.create
    to_record.store_value(@out_attribute.to_s, value)
  end
end