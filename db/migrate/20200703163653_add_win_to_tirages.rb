class AddWinToTirages < ActiveRecord::Migration[6.0]
  def change
    add_column :tirages, :winners, :integer
  end
end
