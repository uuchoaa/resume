class CreateDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :deals do |t|
      t.references :agency, null: false, foreign_key: true
      t.references :recruter, null: false, foreign_key: true
      t.integer :stage

      t.timestamps
    end
  end
end
