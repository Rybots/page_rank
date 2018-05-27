class CreateCurators < ActiveRecord::Migration[5.1]
  def change
    create_table :curators do |t|
      t.string :word
      t.boolean :cron

      t.timestamps
    end
  end
end
