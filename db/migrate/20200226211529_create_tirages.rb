class CreateTirages < ActiveRecord::Migration[6.0]
  def change
    create_table :tirages do |t|
      t.date :date
      t.integer :number1
      t.integer :number2
      t.integer :number3
      t.integer :number4
      t.integer :number5
      t.integer :star1
      t.integer :star2
      t.string :prize

      t.timestamps
    end
  end
end
