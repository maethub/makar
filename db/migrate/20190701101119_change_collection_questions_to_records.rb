class ChangeCollectionQuestionsToRecords < ActiveRecord::Migration[5.2]
  def change
    rename_table :collections_questions, :collections_records

    rename_column :collections_records, :question_id, :record_id
  end
end
