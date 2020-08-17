class AddExternalIdToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :external_id, :string
    add_index :questions, [:source, :external_id], unique: true
  end
end
