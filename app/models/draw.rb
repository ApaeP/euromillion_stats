class Draw < ApplicationRecord
  class << self
    def min_date
      Draw.order(:date).first.date
    end

    def max_date
      Draw.order(:date).last.date
    end
  end
  validates :date, :number1, :number2, :number3, :number4, :number5, :star1, :star2, :won_by, :prize, presence: true
  validates :number1, :number2, :number3, :number4, :number5, :star1, :star2, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 50 }
  validates :won_by, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :date, uniqueness: true

  scope :from_year, -> (year = Time.zone.now.year) { where(date: Date.new(year, 1, 1)..Date.new(year, -1, -1)).order(date: :desc) }
  # scope :from_period,   -> (period, year: Time.now.year, month: Time.now.month, day: Time.now.day, quarter: (Time.now.month / 3.0).ceil) do
  #   range = case period
  #           when :year    then DateTime.new(year).all_year
  #           when :quarter then DateTime.new(year, 3 * quarter).all_quarter
  #           when :month   then DateTime.new(year, month).all_month
  #           when :day     then DateTime.new(year, month, day).all_day
  #           end
  #   where(created_at: range).order(:created_at)
  # end

  def year
    date.year
  end

  def won?
    !won_by.nil?
  end

  def numbers
    [number1, number2, number3, number4, number5]
  end

  def stars
    [star1, star2]
  end
end
