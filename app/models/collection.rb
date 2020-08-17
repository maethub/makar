class Collection < ApplicationRecord
  has_and_belongs_to_many :records
  belongs_to :filter, optional: true

  validates_presence_of :name, :description

  def records=(records)
    self.records << (records - self.records)
  end

  def add_record_ids(ids)
    self.record_ids = (self.records.pluck(:id) + ids)
  end

  def has_record?(r)
    records.include?(r)
  end

  def available_attributes
    Schema.by_collection(self).collect(&:attributes).flatten.uniq
  end

  def export(attributes, include_id = false)
    tbl = value_table(attributes, include_id)
    out = []
    tbl.each do |row|
      out << row.map{ |k, v| [k, (v.nil? ? nil : JSON.parse(v.to_s))] }.to_h
    end
    out
  end

  def value_table(attributes, include_id = false)
    join_queries = []
    where_queries = []

    # Join collections assignments table
    join_queries << "LEFT JOIN collections_records cr ON records.id = cr.record_id "

    attributes.each do |a|
      join_queries << "LEFT JOIN record_values rv_#{a} ON rv_#{a}.name = '#{a}' AND records.id = rv_#{a}.record_id"
      where_queries << "rv_#{a}.data IS NOT NULL"
    end
    query = "SELECT#{ include_id ? ' records.id AS r_id,' : ''} #{attributes.collect{ |a| "rv_#{a}.data as #{a}"}.join(', ')} FROM records #{join_queries.join(" ")} "
    query << "WHERE cr.collection_id = #{self.id} "
    query << "AND (#{where_queries.join(' OR ')})"
    RecordValue.connection.execute(query)
  end

  def update_filter
    return nil unless self.filter

    new_ids = Record.ransack(self.filter.query).result(distinct: true).pluck(:id)
    old_ids = self.records.pluck(:id)

    self.records.delete(Record.where(id: old_ids - new_ids))
    self.records << Record.where(id: (new_ids - old_ids))
  end

  def distinct_values_for_attribute(attr)
    self.records.joins(:record_values).where(record_values: { name: attr }).pluck(:data).uniq
  end

  def drop_all_records!
    Record.transaction do
      # record_values
      sql = "DELETE FROM record_values USING records, collections_records WHERE collections_records.record_id = records.id AND records.id = record_values.record_id AND collections_records.collection_id = #{id}"
      Record.connection.execute(sql)

      # records
      sql = "DELETE FROM records USING collections_records WHERE records.id = collections_records.record_id AND collections_records.collection_id = #{id}"
      Record.connection.execute(sql)

      # collection_assignments
      sql = "DELETE FROM collections_records WHERE collections_records.collection_id = #{id}"
      Record.connection.execute(sql)
    end
  end
end