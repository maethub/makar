class AddFilterToCollections < ActiveRecord::Migration[5.2]
  def change

    add_column :collections, :filter_id, :integer, index: true
  end
end
