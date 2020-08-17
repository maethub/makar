class CreateFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :filters do |t|
      
      t.string :name
      t.jsonb :query

      t.index :name, unique: true
    end
  end
end
