class CreateRecruters < ActiveRecord::Migration[8.1]
  def change
    create_table :recruters do |t|
      t.string :name
      t.references :agency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
