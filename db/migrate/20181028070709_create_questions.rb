class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.text :question
      t.text :answer
      t.string :source
      t.boolean :deactivated
      t.string :url

      t.timestamps
    end
  end
end
