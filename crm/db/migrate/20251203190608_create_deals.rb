class CreateDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :deals do |t|
      t.string :name
      t.string :description
      t.references :recruter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
