class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :name
      t.string :status
      t.string :parameters
      t.text   :output
      t.string :error

      t.timestamps
    end
  end
end
