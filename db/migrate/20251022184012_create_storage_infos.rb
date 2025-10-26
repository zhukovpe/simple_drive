class CreateStorageInfos < ActiveRecord::Migration[8.1]
  def change
    create_table :storage_infos do |t|
      t.string :storage_type, null: false
      t.string :identifier, null: false, index: { unique: true, name: 'unique_identifiers' }

      t.timestamps
    end
  end
end
