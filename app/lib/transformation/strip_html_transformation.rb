class Transformation::StripHtmlTransformation < Transformation

  DESCRIPTION = 'Strips all HTML tags from :in_attribute and saves result in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze

  def init
    @sanitizer = Rails::Html::FullSanitizer.new
  end

  def transform!
    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, @sanitizer.sanitize(r.fetch_value(@in_attribute.to_s)))
    end
  end
end