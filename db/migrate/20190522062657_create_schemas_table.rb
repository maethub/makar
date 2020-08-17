class CreateSchemasTable < ActiveRecord::Migration[5.2]
  def change
    create_table :schemas do |t|
      t.string  :name, nil: false
      t.jsonb   :schema

      t.timestamps
    end
  end
end
