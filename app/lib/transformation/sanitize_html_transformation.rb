class Transformation::SanitizeHtmlTransformation < Transformation

  DESCRIPTION = 'Strips all HTML tags except a, p, b, i br from :in_attribute and saves result in :out_attribute.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection
  }.freeze


  def init
    @sanitizer = Rails::Html::WhiteListSanitizer.new
    @tags = %w(a p b i br)
    @attributes = %w(href style)
  end

  def transform!
    @collection.records.each do |r|
      r.store_value(@out_attribute.to_s, @sanitizer.sanitize(r.fetch_value(@in_attribute.to_s), tags: @tags, attributes: @attributes))
    end
  end
end