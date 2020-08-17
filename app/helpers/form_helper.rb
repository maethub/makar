module FormHelper
  def tag_collection
    tags = {}
    Tag.pluck(:source).uniq.each do |s|
      tags[s.upcase] = Tag.where(source: s).order(:name).pluck(:name, :id).map { |o| ["#{o.first} (#{s})", o.last]}
    end
    tags
  end

  def source_collection
    Question.pluck(:source).uniq
  end

  def collection_collection
    Collection.pluck(:name, :id)
  end

  def question_attributes_collection(collection = nil)
    attributes = collection.available_attributes.map(&:to_sym)
  end

  def dynamic_input_helper(form, key, value)
    options = { required: true}
    if value.is_a? Array
      options = options.merge(value.second)
      value = value.first
    end
    case value
    when :schema
      return form.input key, collection: Schema.all, required: options[:required], input_html: { class: 'ui dropdown' }
    when :file
      return form.input key, as: :file, required: options[:required]
    when :date
      return form.input key, as: :date, html5: true, required: options[:required]
    when :collection
      return form.input key, collection: Collection.all, required: options[:required], input_html: { class: 'ui dropdown' }
    when :bool
      return form.input key, collection: [[true, true], [false, false]], required: options[:required], input_html: { class: 'ui dropdown' }
    when :attribute, :attributes
      return form.input key, collection: question_attributes_collection(@collection), required: true, include_hidden: false, input_html: { class: 'ui dropdown', multiple: true }
    else
      return form.input key, required: options[:required]
    end
  end
end