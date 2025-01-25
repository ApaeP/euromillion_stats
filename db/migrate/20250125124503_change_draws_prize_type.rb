class ChangeDrawsPrizeType < ActiveRecord::Migration[6.1]
  def change
    remove_column :draws, :prize
    add_column :draws, :prize, :integer
  end
end
