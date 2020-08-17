class Transformation::SampleSelectionTransformation < Transformation

  DESCRIPTION = 'Select a random sample of size :sample_size from :from_collection and add it to :out_collection.
                If :selection_attribute is given, the sample set will contain the correct proportion of all values (or only :selection_values)
                compared to the total population size.'

  INPUTS      = {
    sample_size: :string,
    selection_attribute: :string,
    selection_values: :string,
    from_collection: :collection,
    out_collection: :collection
  }.freeze

  def init
    Schema.by_collection(@from_collection).each do |s|
      fail ':selection_attribute must exist in schema definition' unless s.attributes.include?(@selection_attribute)
    end

    @sample_size = @sample_size.to_i
  end

  def transform!
    @selection_values = @selection_values.blank? ? @from_collection.distinct_values_for_attribute(@selection_attribute) : @selection_values.split(',').map { |a| a.strip }

    # Build population
    table = @from_collection.export([@selection_attribute], true)

    # Make buckets
    buckets = {}
    @selection_values.each { |v| buckets[v] = [] }
    bucket_key = @selection_attribute.downcase

    table.each do |r|
      next unless buckets.key? r[bucket_key]
      buckets[r[bucket_key]] << r['r_id']
    end

    # Make records in buckets unique
    buckets.each { |_k, values| values.uniq! }

    # Sample selection
    population_size = @from_collection.records.count.to_f
    sample = []
    # Select small buckets first, to improve chance to get a correct sample
    buckets.sort_by{ |_k, ids| ids.count }.each do |k, ids|
      bucket_sample = []
      bucket_size = ids.count
      bucket_sample_size = (bucket_size.to_f / population_size * @sample_size).ceil

      i = 0
      while bucket_sample.count < bucket_sample_size
        bucket_sample << ids.sample
        bucket_sample.uniq! # Make unique
        bucket_sample = bucket_sample - sample # remove records already in the sample
        i += 1
        fail "Cannot build sample for bucket #{k}" if i > population_size
      end
      sample += bucket_sample
    end

    sample = sample.flatten
    @out_collection.add_record_ids(sample)
  end
end