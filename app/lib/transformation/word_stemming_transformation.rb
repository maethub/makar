class Transformation::WordStemmingTransformation < Transformation

  DESCRIPTION = 'Applies the Snowball stemming algorithm (english language) to :in_attribute and saves the result in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze

  def transform!
    @stemmer = Lingua::Stemmer.new(language: "en")

    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, stem_words(r.fetch_value(@in_attribute.to_s)).strip)
    end
  end

  def stem_words(string)
    stemmed = Lingua.stemmer(string.split)
    return stemmed if stemmed.is_a?(String)
    stemmed.join(' ')
  end
end