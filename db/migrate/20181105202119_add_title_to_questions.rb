class AddTitleToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :title, :string
  end
end
