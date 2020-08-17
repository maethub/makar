class DropTableQuestions < ActiveRecord::Migration[5.2]
  def change
    drop_table :questions
    drop_table :tags
  end
end
