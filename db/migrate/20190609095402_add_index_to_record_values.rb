class AddIndexToRecordValues < ActiveRecord::Migration[5.2]
  def change
    add_column :record_values, :index, :integer, default: 0

    add_index :record_values, [:record_id, :name, :index], unique: true
  end
end
