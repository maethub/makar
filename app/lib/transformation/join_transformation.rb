class Transformation::JoinTransformation < Transformation

  DESCRIPTION = 'Adds values :in_attribute from records in :from_collection to records in :collection as :out_attribute if the value in :column is identical.'

  INPUTS      = {
    in_attribute: :string,
    out_attribute: :string,
    collection: :collection,
    from_collection: :collection,
    column: :string
  }.freeze

  def init
    Schema.by_collection(@from_collection).each do |s|
      fail ':in_attribute must exist in schema definition' unless s.attributes.include?(@in_attribute)
    end

    Schema.by_collection(@collection).each do |s|
      fail ':out_attribute must exist in schema definition' unless s.attributes.include?(@out_attribute)
    end
  end

  def transform!
    query = <<-SQL
    SELECT * FROM (
      SELECT r.id AS id_left, rv.name, rv.data  FROM record_values AS rv
      JOIN records r ON rv.record_id = r.id
      JOIN collections_records cr on r.id = cr.record_id
      WHERE rv.name = '#{@column}' AND cr.collection_id = #{@collection.id}
    ) t1
    JOIN (
      SELECT r.id AS id_right, rv.name, rv.data  FROM record_values AS rv
      JOIN records r ON rv.record_id = r.id
      JOIN collections_records cr on r.id = cr.record_id
      WHERE rv.name = '#{@column}' AND cr.collection_id = #{@from_collection.id}
    ) t2 ON t1.data = t2.data;
    SQL

    joined_records = RecordValue.connection.execute(query)
    joined_records.each do |jr|
      left_r = Record.find(jr['id_left'])
      right_r = Record.find(jr['id_right'])
      left_r.store_value(@out_attribute.to_s, right_r.fetch_value(@in_attribute.to_s))
    end
  end
end