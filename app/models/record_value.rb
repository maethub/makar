class RecordValue < ApplicationRecord
  upsert_keys :record_id, :name, :index
  belongs_to :record, touch: true

  scope :with_name, ->(name) { where(name: name) }
  scope :from_schema, ->(schema) { joins(:record).where(records: { schema_id: schema.id}) }

  ransacker :data do |parent|
    Arel.sql("data::TEXT")
  end
end
