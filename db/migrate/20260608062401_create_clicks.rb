class CreateClicks < ActiveRecord::Migration[7.1]
  def change
    create_table :clicks do |t|
      t.integer :count
      t.references :short_url, foreign_key: true
      t.timestamps
    end
  end
end
