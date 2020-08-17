class CreateRecordsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.integer :schema_id, nil: false, index: true
      t.boolean :deactivated, default: false

      t.timestamps
    end
  end
end
