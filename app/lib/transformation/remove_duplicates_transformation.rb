class Transformation::RemoveDuplicatesTransformation < Transformation

  DESCRIPTION = 'Accepts comma-separated list of attributes. Based on the concatenation of those attributes, duplicate records will be deleted.'

  INPUTS      = {
    attributes: :string,
    collection: :collection,
  }.freeze

  def init
    # Do nothing
  end

  def transform!
    attributes_list = @attributes.split(',').collect{ |a| a.strip}

    dup_hash = {}
    @collection.records.each do |r|
      key = ''
      attributes_list.each do |a|
        key << r.fetch_value(a).to_s
        key << '#'
      end

      if dup_hash.key?(key)
        r.destroy
      else
        dup_hash[key] = r.id
      end
    end
  end
end