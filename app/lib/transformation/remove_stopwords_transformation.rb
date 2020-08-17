class Transformation::RemoveStopwordsTransformation < Transformation

  DESCRIPTION = 'Removes all stopwords (Snowball stopword list, english language) in :in_attribute and saves the result in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze

  def transform!
    @sieve = Stopwords::Snowball::Filter.new 'en'

    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, remove_words(r.fetch_value(@in_attribute.to_s)).strip)
    end
  end

  def remove_words(string)
    (@sieve.filter string.split).join(' ')
  end
end