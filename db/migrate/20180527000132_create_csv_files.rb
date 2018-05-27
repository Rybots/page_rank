class CreateCsvFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :csv_files do |t|
      t.string :file_name
      t.integer :curator_id

      t.timestamps
    end
  end
end
