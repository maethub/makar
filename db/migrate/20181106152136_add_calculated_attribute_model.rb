class AddCalculatedAttributeModel < ActiveRecord::Migration[5.2]
  def change

    create_table :calculated_attributes do |t|
      t.integer :objectable_id
      t.string :objectable_type
      t.string :name, null: false, index: true
      t.jsonb :data

      t.timestamps
    end

    add_index :calculated_attributes, [:objectable_id, :objectable_type, :name], unique: true, name: 'idx_calc_attr_on_obj_id_and_obj_type_and_name'
  end
end
