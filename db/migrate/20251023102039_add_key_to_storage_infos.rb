class AddKeyToStorageInfos < ActiveRecord::Migration[8.1]
  def change
    add_column :storage_infos, :key, :string, null: false
    add_index :storage_infos, :key, unique: true, name: 'unique_keys'
  end
end
