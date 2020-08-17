class CreateRecordValuesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :record_values do |t|

      t.string  :name, nil: false
      t.string  :value_type, nil: false
      t.jsonb   :data
      t.string  :value_hash

      t.timestamps
    end
  end
end
