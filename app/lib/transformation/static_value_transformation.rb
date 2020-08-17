class Transformation::StaticValueTransformation < Transformation

  DESCRIPTION = 'Inserts :value at :attribute for all records in :collection.'

  INPUTS      = {
    value: :string,
    attribute: :string,
    collection: :collection
  }.freeze

  def init
    Schema.by_collection(@collection).each do |s|
      fail ':attribute must exist in schema definition' unless s.attributes.include?(@attribute)
    end
  end

  def transform!
    @collection.records.each do |r|
      r.store_value(@attribute.to_s, @value)
    end
  end
end