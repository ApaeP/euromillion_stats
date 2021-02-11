class AddYearidToTirages < ActiveRecord::Migration[6.0]
  def change
    add_reference :tirages, :year, null: false, foreign_key: true
  end
end
