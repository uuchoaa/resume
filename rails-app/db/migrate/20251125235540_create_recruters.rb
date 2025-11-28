class CreateRecruters < ActiveRecord::Migration[8.1]
  def change
    create_table :recruters do |t|
      t.references :agency, null: false, foreign_key: true
      t.string :name
      t.string :linkedin_chat_url

      t.timestamps
    end
  end
end
