class Draw < ApplicationRecord
  class << self
    def min_date
      Draw.minimum(:date) || Date.new(2004, 2, 13)
    end

    def max_date
      Draw.maximum(:date) || Time.zone.today
    end
  end

  validates :date, :number1, :number2, :number3, :number4, :number5, :star1, :star2, :winners, :prize, presence: true
  validates :number1, :number2, :number3, :number4, :number5, :star1, :star2, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 50 }
  validates :winners, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :date, uniqueness: true

  scope :won, -> { where.not(winners: 0) }
  scope :tuesday, -> { where('extract(dow from date) = ?', 2) }
  scope :friday, -> { where('extract(dow from date) = ?', 5) }
  scope :by_date, -> { order(date: :desc) }

  def year
    date.year
  end

  def won?
    winners.present? && winners > 0
  end

  def numbers
    [number1, number2, number3, number4, number5]
  end

  def stars
    [star1, star2]
  end

  def prize_amount
    prize || 0
  end
end
