class RemoveNMAssociationBetweenRecordValues < ActiveRecord::Migration[5.2]
  def change
    drop_table :record_value_assignments
    add_reference :record_values, :record, index: true
  end
end
