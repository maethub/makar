class CreateJoinTableQuestionCollection < ActiveRecord::Migration[5.2]
  def change
    create_join_table :questions, :collections do |t|
      t.index [:question_id, :collection_id]
      t.index [:collection_id, :question_id]
    end
  end
end
