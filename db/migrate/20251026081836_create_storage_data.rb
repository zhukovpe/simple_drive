class CreateStorageData < ActiveRecord::Migration[8.1]
  def change
    create_table :storage_data do |t|
      t.string :key, null: false
      t.binary :blob

      t.timestamps
    end
  end
end
