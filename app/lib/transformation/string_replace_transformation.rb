class Transformation::StringReplaceTransformation < Transformation

  DESCRIPTION = 'Replaces all occurrences of :to_replace in :in_attribute with :replacement.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection,
    to_replace: :string,
    replacement: :string
  }.freeze

  def transform!
    # Convert to Regex
    regex = Regexp.new(@to_replace)

    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, r.fetch_value(@in_attribute.to_s).gsub(regex, @replacement).strip)
    end
  end
end