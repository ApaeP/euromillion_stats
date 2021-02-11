class AddWinToTirages < ActiveRecord::Migration[6.0]
  def change
    add_column :tirages, :won_by, :integer
  end
end
