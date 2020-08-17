class Transformation::CountOccurrenceTransformation < Transformation

  DESCRIPTION = 'Counts how often the value of :in_attribute is present in :search_collection at :search_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection,
    search_collection: :collection,
    search_attribute: :string
  }.freeze

  def init

  end

  def transform!
    @collection.records.each do |r|
      search_value =  r.fetch_value(@in_attribute.to_s)
      count = @search_collection.records.includes(:record_values).where(record_values: { name: @search_attribute, data: search_value}).count
      r.store_value(@out_attribute, count)
    end
  end
end