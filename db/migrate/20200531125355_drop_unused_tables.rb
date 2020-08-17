class DropUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :questions_tags
    drop_table :calculated_attributes
  end
end
