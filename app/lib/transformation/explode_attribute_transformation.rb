class Transformation::ExplodeAttributeTransformation < Transformation

  DESCRIPTION = 'Split values on :split and save list in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection,
    split: :string
  }.freeze

  def init
    @collection.records.collect(&:schema).uniq.each do |s|
      fail ':out_attribute must have :multiple => true in schema definition' if !s.multiple?(@out_attribute)
    end
  end

  def transform!
    # Convert to Regex
    regex = Regexp.new(@split)

    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, r.fetch_value(@in_attribute.to_s).split(regex).compact)
    end
  end
end