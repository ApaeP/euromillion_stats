class CreateYears < ActiveRecord::Migration[6.0]
  def change
    create_table :years do |t|
      t.string :year
      t.string :url

      t.timestamps
    end
  end
end
