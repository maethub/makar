class AddDefaultToQuestionsDeactivated < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :deactivated, :boolean, default: false
  end
end
