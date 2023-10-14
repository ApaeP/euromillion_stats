class ResetSchema < ActiveRecord::Migration[6.0]
  def change
    create_table :draws do |t|
      t.date :date
      t.integer :number1
      t.integer :number2
      t.integer :number3
      t.integer :number4
      t.integer :number5
      t.integer :star1
      t.integer :star2
      t.integer :won_by
      t.string :prize
      t.timestamps
    end

    Draw.all.each do |tirage|
      Draw.create!(
        date: tirage.date,
        number1: tirage.number1,
        number2: tirage.number2,
        number3: tirage.number3,
        number4: tirage.number4,
        number5: tirage.number5,
        star1: tirage.star1,
        star2: tirage.star2,
        won_by: tirage.won_by,
        prize: tirage.prize
      )
    end
    drop_table :tirages
    drop_table :years
  end
end
