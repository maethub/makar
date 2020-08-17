class CreateRecordValuesAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :record_value_assignments, id: false do |t|
      t.belongs_to :record, index: true
      t.belongs_to :record_value, index: true
    end
  end
end
