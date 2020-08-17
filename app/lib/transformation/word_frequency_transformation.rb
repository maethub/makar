class Transformation::WordFrequencyTransformation < Transformation

  DESCRIPTION = 'Lists all words in :in_attribute with their frequency and saves the result in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze

  def transform!
    @collection.records.each do |r|
      input = r.fetch_value(@in_attribute.to_s).split(/\s+/)
      words = input.each_with_object(Hash.new(0)){ |k,hash| hash[k] += 1}
      r.store_value(@out_collection.to_s, words)
    end
  end
end